jbxtmp="$(pwd)/_jbxtmp"
mkdir $jbxtmp

if [ ! -z "$subfolder" ]; then
    cd "$subfolder"
    echo "Building from subfolder $subfolder..."
fi

# Maven
if [ -e pom.xml ]; then
    echo "Found maven script..."
    dljc -t print -o $jbxtmp -- \
         mvn compile -Dmaven.repo.local="$(pwd)/.m2" > $jbxtmp/result.json

# Gradle
elif [ -e build.gradle ]; then
    echo "Found gradle script..."
    GRADLE_USER_HOME=$(pwd) dljc -t print -o $jbxtmp -- \
       gradle build > $jbxtmp/result.json
# Ant
elif [ -e build.xml ]; then
    echo "Found ant build script..."
    dljc -t print -o $jbxtmp -- \
         ant > $jbxtmp/result.json

# Fail if no build-script could be found
else
    echo "Couldn't find a build script in $src"
    exit -1
fi

echo "Build completed with return code $?..."

files=$(jq -r '.javac_commands[].java_files[]' $jbxtmp/result.json)

for file in $files; do
    path=`sed -n '/package .*;/{s/package//g; s/[[:space:]]//g; s/;//; s/\./\//g; p}' $file`
    mkdir -p "$jbxtmp/src/$path"
    cp "$file" "$jbxtmp/src/$path"
done

mkdir $jbxtmp/lib

classpath=$(jq -r '[
  .javac_commands[].javac_switches | .d as $r
 | .classpath | ltrimstr($r) | split(":")
  ] | add[] | select(. != "")' $jbxtmp/result.json)

for path in $classpath; do
    echo "Copying over classpath $path..."
    if [[ $path == *.jar ]]; then
        mkdir _out
        unzip -qq -o "$path" -d _out
        path=_out
    fi
    (cd "$path"; find . -name "*.class" | cpio --quiet -pdm $jbxtmp/lib)
    if [[ -e _out ]]; then rm -r _out; fi
done

pushd $jbxtmp > /dev/null

find src -name "*.java" > sources.txt

mkdir classes

javac -encoding UTF-8 -cp classes:lib -d classes @sources.txt

classes=$(find classes -name "*.class" | sed 's/.class//;s/\//./g;s/classes.//');

echo $classes | sed "s/ /\n/g" > classes.txt
javap -classpath classes $classes > declarations.txt

# Finding mainclasses
sed -e '/.*public static .*void main(java.lang.String\[\])/{g;p;}' \
    -e 's/.*class \([[:alnum:].]*\).*/\1/;T;h' \
    -n declarations.txt > mainclasses.txt

mkdir -p share/java

jar cf $jbxtmp/share/java/$name.jar -C classes .
jar cf $jbxtmp/share/java/$name.jar -C lib .

popd > /dev/null
