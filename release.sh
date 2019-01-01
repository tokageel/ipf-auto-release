node jsonDiffToCsv.js | while read row; do
    arr=(`echo $row | tr -s ',' ' '`)
    file=${arr[0]}
    version=${arr[1]}
    releaseTag=${arr[2]}
    releaseFileName=${file}-${version}.ipf

    targetPath=$(find . -name ${file})
    if [ -z "${targetPath}" ] ; then
        echo ${file}がみつかりません
        continue
    fi
    echo ${targetPath}
    pushd .
    cd ${targetPath}
    ./gradlew build
    result=$?
    ipfFileName=$(./gradlew info | grep filename | sed -e "s/.*: //g")
    popd
    if [ ${result} -ne 0 ] ; then
        echo "Build failed"
        continue
    fi
    mv "${targetPath}/build/${ipfFileName}" "${releaseFileName}"
    currentBranch=$(git rev-parse --abbrev-ref HEAD)
    ghr -c "${currentBranch}" "${releaseTag}" "${releaseFileName}"
done
