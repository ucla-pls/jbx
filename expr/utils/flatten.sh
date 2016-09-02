jbxtmp=_jbxtmp
mkdir $jbxtmp

# Maven
if [ -e pom.xml ]; then
    echo "Found maven project..."
    dljc -t print -o $jbxtmp -- mvn compile -Dmaven.repo.local="$(pwd)/.m2" > $jbxtmp/result.json

    # Ant
elif [ -e build.xml ]; then
    echo "Found ant build script..."
    dljc -t print -o $jbxtmp -- ant > $jbxtmp/result.json

    # Fail if no build-script could be found
else
    echo "Couldn't find a build script in $src"
    exit -1
fi

files=$(jq -r '.javac_commands[].java_files[]' $jbxtmp/result.json)

for file in $files; do
    path=`sed -n '/package .*;/{s/package//g; s/[[:space:]]//g; s/;//; s/\./\//g; p}' $file`
    mkdir -p "$jbxtmp/src/$path"
    cp "$file" "$jbxtmp/src/$path"
done

pushd $jbxtmp > /dev/null

find src -name "*.java" > sources.txt
mkdir classes

javac -encoding UTF-8 -d classes @sources.txt

classes=$(find classes -name "*.class" | sed 's/.class//;s/\//./g;s/classes.//');

echo $classes | sed "s/ /\n/g" > classes.txt
javap -classpath classes $classes > declarations.txt

# Finding mainclasses
sed -e '/.*public static .*void main(java.lang.String\[\])/{g;p;}' \
    -e 's/.*class \([[:alnum:].]*\).*/\1/;T;h' \
    -n declarations.txt > mainclasses.txt

mkdir -p share/java

cd classes
jar cf ../share/java/$name.jar .

popd > /dev/null
