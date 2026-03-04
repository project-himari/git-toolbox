#!/bin/csh

# 現在のディレクトリ以下を find で探索
foreach dir (`find . -type d`)
    # ls -A で中身を確認、空なら .tmp を作成
    set files=`ls -A $dir`
    if ("$files" == "") then
        touch "$dir/.gitkeep"
        echo "Created $dir/.gitkeep"
    endif
end

