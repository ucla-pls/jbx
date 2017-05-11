jbxtmp="$(pwd)/_jbxtmp"
mkdir $jbxtmp

mkdir -p $out/info

if [ ! -z "$subfolder" ]; then
    cd "$subfolder"
    echo "Building from subfolder $subfolder..."
    echo "$subfolder" > $out/info/subfolder
fi

# Maven
if [ -e pom.xml ]; then
    echo "Found maven script..."
    dljc -t print -o $jbxtmp -- \
         mvn compile -Dmaven.repo.local="$(pwd)/.m2" > $out/info/result.json
    echo "maven" > $out/info/buildwith

# Gradle
elif [ -e build.gradle ]; then
    echo "Found gradle script..."
    GRADLE_USER_HOME=$(pwd) dljc -t print -o $jbxtmp -- \
       gradle build > $out/info/result.json
    echo "gradle" > $out/info/buildwith

# Ant
elif [ -e build.xml ]; then
    echo "Found ant build script..."
    dljc -t print -o $jbxtmp -- \
         ant > $out/info/result.json
    echo "ant" > $out/info/buildwith

# Fail if no build-script could be found
else
    echo "none" > $out/info/buildwith
    echo "Couldn't find a build script in $src"
    exit 0
fi

echo "Build completed with return code $?..."

pushd $out > /dev/null

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
    mkdir -p "$out/src/$path"
    cp "$file" "$out/src/$path"
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
    if [[ "$path" == *.class ]]; then
	folder=$(dirname "$path")
        classname=$(basename "$path")
        classname=${classname%.class}
        package=$(javap -classpath "$folder" "$classname" | head -1 | sed "s/.* \(\S*\)${classname}[{ ].*/\1/")
	package=${package%.}
        folder="$out/lib/${package/\./\/}"
        mkdir -p "$folder"
        cp "$path" "$folder"
    else
        if [[ "$path" == *.jar ]]; then
            mkdir _out
            unzip -qq -o "$path" -d _out
            path=_out
        fi
        (cd "$path"; find . -name "*.class" | sort | cpio --quiet -updm $out/lib)
        if [[ -e _out ]]; then rm -r _out; fi
    fi
done

find src -name '*.java' | sort > info/sources

javac -encoding UTF-8 -cp classes:lib -d classes @info/sources

classes=$(find classes -name "*\.class" | sed 's/\.class//;s/\//./g;s/classes.//' | sort );

echo "$classes" | sed "s/ /\n/g" > info/classes
javap -classpath classes $classes > info/declarations

# Finding mainclasses
sed -e '/.*public static .*void main(java.lang.String\[\])/{g;p;}' \
    -e 's/.*class \([[:alnum:]_$.]*\).*/\1/;T;h' \
    -n info/declarations > info/mainclasses

popd > /dev/null
