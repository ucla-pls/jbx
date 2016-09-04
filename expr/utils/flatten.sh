jbxtmp="$(pwd)/_jbxtmp"
mkdir $jbxtmp

mkdir $jbxtmp/info

if [ ! -z "$subfolder" ]; then
    cd "$subfolder"
    echo "Building from subfolder $subfolder..."
    echo "$subfolder" > $jbxtmp/subfolder
fi

# Maven
if [ -e pom.xml ]; then
    echo "Found maven script..."
    dljc -t print -o $jbxtmp -- \
         mvn compile -Dmaven.repo.local="$(pwd)/.m2" > $jbxtmp/info/result.json
    echo "maven" > $jbxtmp/info/buildwith

# Gradle
elif [ -e build.gradle ]; then
    echo "Found gradle script..."
    GRADLE_USER_HOME=$(pwd) dljc -t print -o $jbxtmp -- \
       gradle build > $jbxtmp/info/result.json
    echo "gradle" > $jbxtmp/info/buildwith

# Ant
elif [ -e build.xml ]; then
    echo "Found ant build script..."
    dljc -t print -o $jbxtmp -- \
         ant > $jbxtmp/info/result.json
    echo "ant" > $jbxtmp/info/buildwith

# Fail if no build-script could be found
else
    echo "none" > $jbxtmp/info/buildwith
    echo "Couldn't find a build script in $src"
    exit 0
fi

echo "Build completed with return code $?..."

pushd $jbxtmp > /dev/null

mkdir -p lib src classes

files=$(jq -r '.javac_commands[].java_files[]' info/result.json)

for file in $files; do
    path=$(sed -n '
       /^[[:space:]]*package [[:space:][:alnum:].].*;/{
         s/.*package//g
         s/[[:space:]]//g
         s/;.*//
         s/\./\//g
         p
         q
       }' $file)
    mkdir -p "$jbxtmp/src/$path"
    cp "$file" "$jbxtmp/src/$path"
done


classpath=$(jq -r '
  [ .javac_commands[].javac_switches
  | .d as $r
  | select(has("classpath"))
  | .classpath
  | ltrimstr($r)
  | split(":")
  ] | add
    | unique[]
    | select(. != "")' info/result.json)

echo "$classpath" > info/classpath

for path in $classpath; do
    echo "Copying over classpath $path..."
    if [[ $path == *.jar ]]; then
        mkdir _out
        unzip -qq -o "$path" -d _out
        path=_out
    fi
    (cd "$path"; find . -name "*.class" | cpio --quiet -updm $jbxtmp/lib)
    if [[ -e _out ]]; then rm -r _out; fi
done

find src -name '*.java' > info/sources

javac -encoding UTF-8 -cp classes:lib -d classes @info/sources

classes=$(find classes -name "*.class" | sed 's/.class//;s/\//./g;s/classes.//');

echo "$classes" | sed "s/ /\n/g" > info/classes
javap -classpath classes $classes > info/declarations

# Finding mainclasses
sed -e '/.*public static .*void main(java.lang.String\[\])/{g;p;}' \
    -e 's/.*class \([[:alnum:].]*\).*/\1/;T;h' \
    -n info/declarations > info/mainclasses

mkdir -p share/java

jar cf $jbxtmp/share/java/$name.jar -C classes .
jar uf $jbxtmp/share/java/$name.jar -C lib .

popd > /dev/null
