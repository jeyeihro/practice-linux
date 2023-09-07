#!/bin/bash
#
# Linux初心者用演習問題生成スクリプト
#

game_dir=""
declare -A already_generated
declare -a random_strings
temp_file=$(mktemp)

stock(){
    while [ ${#random_strings[@]} -lt 30 ]; do
        local random_string=$(openssl rand -base64 100 | tr -dc 'a-z' | head -c 4)
        if [ -z "${already_generated[$random_string]}" ]; then
            already_generated[$random_string]=1
            random_strings+=($random_string)
        fi
    done
    echo "${random_strings[@]}" > "$temp_file"
}

pop(){
    read -ra random_strings < "$temp_file"
    if [ ${#random_strings[@]} -gt 0 ]; then
        echo "${random_strings[0]}"
        echo "${random_strings[@]:1}" > "$temp_file"
    else
        echo "Error: No more strings left!"
        exit 1
    fi
}

uninstall_app() {
    while true; do
        # 削除確認のプロンプト表示
        echo "ゲームをアンインストールします。"
        read -p "アンインストールしてよろしいですか？（Y/n）" yn
        case $yn in
            [Yy]* )
                # ディレクトリの削除
                rm -rf practice_linux
                echo ""
                echo "ゲームをアンインストールしました。"
                break;;
            [Nn]* )
                echo "アンインストールをキャンセルしました。"
                exit;;
            * ) echo "Yまたはnを入力してください。";;
        esac
    done

    echo "あとはこのshファイル（practice_linux.sh）を手動で削除してください。"
    echo "お疲れさまでした。"
}

initialize_app() {
    echo "ゲームを初期化します。"
    echo ""
    if [ -d "practice_linux" ]; then
        while true; do
            # 削除確認のプロンプト表示
            echo "既にアプリのディレクトリが存在します。"
            echo "スコアはすべて削除されます。"
            echo ""
            read -p "削除してよろしいですか？（Y/n）" yn
            case $yn in
                [Yy]* )
                    # ディレクトリの削除
                    rm -rf practice_linux
                    echo "ディレクトリを削除しました。"
                    break;;
                [Nn]* )
                    echo "処理を終了します"
                    exit;;
                * ) 
                    echo ""
                    echo "Yまたはnを入力してください。"
                    echo "";;
            esac
        done
    else
        echo "初期化中です。"
    fi

    # ディレクトリの作成
    mkdir -p practice_linux/games
    echo "初期化処理が完了しました。"
}

initialize_game() {
    if [ ! -d "practice_linux" ]; then
        echo "practice_linuxへようこそ！"
        initialize_app
    fi

    games_root="practice_linux/games"

    # gamesディレクトリの下の数値のみのディレクトリ名の最大値を取得
    max_game=$(ls "$games_root" | grep '^[0-9]*$' | sort -n | tail -1)

    # max値が存在しない場合
    if [ -z "$max_game" ]; then
        max_game=0
    fi

    # max値ディレクトリが存在する場合（その下に抜けがあろうが）ゲームを終了
    if [ "$max_game" -eq "999" ]; then
        echo "ゲームの記録が限界に達しています。"
        echo ""
        echo "./practice_linux.sh format"
        echo "を実行してすべてのゲームデータを初期化する、もしくは"
        echo ""
        echo "./practice_linux.sh score delete <number>"
        echo "を実行して不要なゲームデータを削除してください。"
        exit
    fi

    # 次の数値を計算
    next_game=$(printf "%03d" $((10#$max_game + 1)))

    # ゲーム用ディレクトリを新規作成
    mkdir "${games_root}/${next_game}"
    # グローバル変数を初期化
    game_dir="${games_root}/${next_game}"
    # ロックファイルを生成
    echo $game_dir > practice_linux/practice_linux.lock

    # ゲーム用ディレクトリのメタデータディレクトリを新規作成
    mkdir "${game_dir}/.metadata"
    # 作成日時・作成者を保存
    local current_datetime=$(date "+%Y%m%d%H%M%S")
    local username=$(whoami)
    echo "$current_datetime" > ${game_dir}/.metadata/created_at
    echo "$username" > ${game_dir}/.metadata/created_by
}

generate_directory_structure() {
    # 各種デフォルトのディレクトリを生成
    mkdir -p "${game_dir}/.metadata/rand/origin"
    mkdir -p "${game_dir}/.metadata/rand/append"
    mkdir -p "${game_dir}/.metadata/rand/exists/file"
    mkdir -p "${game_dir}/.metadata/rand/exists/dir"
    mkdir -p "${game_dir}/.metadata/rand/not_exists/file"
    mkdir -p "${game_dir}/.metadata/rand/not_exists/dir"
    mkdir -p "${game_dir}/.metadata/rand/permission/file"
    mkdir -p "${game_dir}/.metadata/rand/permission/dir"
    mkdir -p "${game_dir}/.metadata/rand/timestamp"
    mkdir -p "${game_dir}/.metadata/rand/modify"
    mkdir -p "${game_dir}/.metadata/score"
    mkdir -p "${game_dir}/bin/a"
    mkdir -p "${game_dir}/bin/b"
    mkdir -p "${game_dir}/logs"
    # 各種デフォルトのファイルを生成
    cat > ${game_dir}/bin/a/proc.sh <<EOF
#!/bin/bash

echo "aaa"
EOF
    chmod 624 ${game_dir}/bin/a/proc.sh

    cat > ${game_dir}/bin/b/proc.sh <<EOF
#!/bin/bash

echo "bbb"
EOF

    chmod 642 ${game_dir}/bin/b/proc.sh
}

generate_logs() {
    # IPアドレスの定義数
    local NUM_IP=20
    # 検索文字列の定義数
    local NUM_TRG=30
    # 1ログファイル当たりの行数
    local NUM_LINES_PER_FILE=$((NUM_IP*NUM_TRG/3))
    declare -a ip_addresses
    declare -a log_strings
    declare -a log_entries

    # IPアドレスのリストを生成
    for i in $(seq 1 $NUM_IP); do
        local ip="$(shuf -i 10-254 -n 1).$(shuf -i 10-254 -n 1).$(shuf -i 10-254 -n 1).$i"
        ip_addresses+=("$ip")
    done

    # 検索文字列のリストを生成
    for i in $(seq 1 $NUM_TRG); do
        log_strings+=("hoge$(printf "%03d" $i)")
    done

    # IPアドレスとログ文字列のペアを生成
    for ip in "${ip_addresses[@]}"; do
        for log_string in "${log_strings[@]}"; do
            log_entries+=("$ip $log_string")
        done
    done

    # シャッフルして、結果を3つの配列に格納
    IFS=$'\n' read -d '' -r -a shuffled_logs < <(printf "%s\n" "${log_entries[@]}" | shuf && printf '\0')

    local yesterday=$(date --date="1 day ago" +%Y%m%d)
    local day_before_yesterday=$(date --date="2 days ago" +%Y%m%d)
    local two_days_before=$(date --date="3 days ago" +%Y%m%d)

    for day in $two_days_before $day_before_yesterday $yesterday; do
        local filename="${game_dir}/logs/app.log.$day"
        
        # 既存のログファイルが存在する場合はファイルを削除
        [ -f $filename ] && rm $filename

        local seconds=0

        # ログを生成
        for i in $(seq 1 $NUM_LINES_PER_FILE); do
            local time=$(printf "%02d:%02d:%02d" $(($seconds / 3600)) $(($seconds % 3600 / 60)) $(($seconds % 60)))
            echo "${shuffled_logs[$i]} $time" >> $filename
            seconds=$((seconds + 4))
        done

        # 次の日のログファイルのために使用済みのログエントリを配列から削除
        shuffled_logs=("${shuffled_logs[@]:$NUM_LINES_PER_FILE}")
    done

    # ログファイルの中から正答をランダムに決定し、ファイルに保持
    local selected_entry=$(
    for file in "${game_dir}/logs/app.log.$two_days_before}" "${game_dir}/logs/app.log.$day_before_yesterday" "${game_dir}/logs/app.log.$yesterday"; do
        [ -f "$file" ] && awk '{print FILENAME " " $0}' "$file"
    done | shuf -n 1
    )

    # 1つ目のフィールドの末尾8文字を取得
    part1=$(echo "$selected_entry" | awk '{print substr($1,length($1)-7,8)}')

    # 4つ目のフィールドから`:`を取り除く
    part2=$(echo "$selected_entry" | awk '{gsub(":","",$4); print $4}')

    # 2つの部分を結合
    result="${part1}${part2}"

    echo "$result" > "${game_dir}/.metadata/target_log_answer"

    echo "${selected_entry// /,}" > "${game_dir}/.metadata/target_log"    
}

# ディレクトリを作成
create_directory() {
    local resourcekey=$1
    local resourcename=$2
    local dirpath=$3

    mkdir -p "$dirpath"

    set_origin "$resourcekey" "$resourcename" "$dirpath"
}

# 空ファイルを作成
create_file(){
    local resourcekey=$1
    local resourcename=$2
    local dirpath=$3

    touch "$dirpath/$resourcename"

    set_origin "$resourcekey" "$resourcename" "$dirpath/$resourcename"
}

set_origin(){
    local resourcekey=$1
    local resourcename=$2
    local path=$3

    echo "${resourcename} ${path}" > "${game_dir}/.metadata/rand/origin/${resourcekey}"
}

set_append(){
    local resourcekey=$1
    local resourcename=$2

    echo "${resourcename}" > "${game_dir}/.metadata/rand/append/${resourcekey}"
}

get_origin_name(){
    local resourcekey=$1
    read -ra GET <<< "$(head -n 1 ${game_dir}/.metadata/rand/origin/${resourcekey})"
    echo "${GET[0]}"
}

get_origin_path(){
    local resourcekey=$1
    read -ra GET <<< "$(head -n 1 ${game_dir}/.metadata/rand/origin/${resourcekey})"
    echo "${GET[1]}"
}

get_append(){
    local resourcekey=$1
    read -ra GET <<< "$(head -n 1 ${game_dir}/.metadata/rand/append/${resourcekey})"
    echo "${GET[0]}"
}

create_exists_dir(){
    local key=$1
    local value=$2

    echo "$value" > "${game_dir}/.metadata/rand/exists/dir/${key}"    
}

create_exists_file(){
    local key=$1
    local value=$2

    echo "$value" > "${game_dir}/.metadata/rand/exists/file/${key}"
}

create_not_exists_dir(){
    local key=$1
    local value=$2

    echo "$value" > "${game_dir}/.metadata/rand/not_exists/dir/${key}"    
}

create_not_exists_file(){
    local key=$1
    local value=$2

    echo "$value" > "${game_dir}/.metadata/rand/not_exists/file/${key}"
}

create_permission_directory(){
    local key=$1
    local path=$2
    local permission=$3

    echo "$path $permission" > "${game_dir}/.metadata/rand/permission/dir/${key}"
}

create_permission_file(){
    local key=$1
    local path=$2
    local permission=$3

    echo "$path $permission" > "${game_dir}/.metadata/rand/permission/file/${key}"
}

create_timestamp(){
    local key=$1
    local path=$2
    local timestamp=$3

    echo "$path $timestamp" > "${game_dir}/.metadata/rand/timestamp/${key}"
}

create_modify(){
    local key=$1
    local path=$2
    local contents=$3

    echo "$path $contents" > "${game_dir}/.metadata/rand/modify/${key}"
}

generate_quiz_files() {
    # ランダム文字列を定義
    stock
    # ディレクトリ名・ファイル名を初期化
    dir1=$(pop)
    dir2=$(pop)
    dir3=$(pop)
    subdir1=$(pop)
    subdir2=$(pop)
    subdir3=$(pop)
    subdir4=$(pop)
    subdir5=$(pop)
    subdir6=$(pop)
    subsubdir1=$(pop)
    subsubdir2=$(pop)
    subsubdir3=$(pop)
    subsubdir4=$(pop)
    subsubdir5=$(pop)
    subsubdir6=$(pop)
    subsubdir7=$(pop)
    file1=$(pop)
    file2=$(pop)
    file3=$(pop)
    file4=$(pop)
    file5=$(pop)
    file6=$(pop)
    file7=$(pop)
    file8=$(pop)
    file9=$(pop)
    file10=$(pop)
    file11=$(pop)
    file12=$(pop)
    file13=$(pop)
    file14=$(pop)

    # ディレクトリを配置
    create_directory "dir1" "$dir1" "$game_dir/$dir1"
    create_directory "subdir1" "$subdir1" "$game_dir/$dir1/$subdir1"
    create_directory "subdir2" "$subdir2" "$game_dir/$dir1/$subdir2"
    create_directory "subdir3" "$subdir3" "$game_dir/$dir1/$subdir3"
    create_directory "dir2" "$dir2" "$game_dir/$dir2"
    create_directory "subdir4" "$subdir4" "$game_dir/$dir2/$subdir4"
    create_directory "subsubdir1" "$subsubdir1" "$game_dir/$dir2/$subdir4/$subsubdir1"
    create_directory "subsubdir2" "$subsubdir2" "$game_dir/$dir2/$subdir4/$subsubdir2"
    create_directory "subdir5" "$subdir5" "$game_dir/$dir2/$subdir5"
    create_directory "subsubdir3" "$subsubdir3" "$game_dir/$dir2/$subdir5/$subsubdir3"
    create_directory "subsubdir4" "$subsubdir4" "$game_dir/$dir2/$subdir5/$subsubdir4"
    create_directory "subdir6" "$subdir6" "$game_dir/$dir2/$subdir6"
    create_directory "subsubdir5" "$subsubdir5" "$game_dir/$dir2/$subdir6/$subsubdir5"
    create_directory "subsubdir6" "$subsubdir6" "$game_dir/$dir2/$subdir6/$subsubdir6"

    # ファイルを配置
    create_file "file1" "$file1" "$game_dir/$dir1/$subdir1"
    create_file "file2" "$file2" "$game_dir/$dir1/$subdir1"
    create_file "file3" "$file3" "$game_dir/$dir1/$subdir2"
    create_file "file4" "$file4" "$game_dir/$dir1/$subdir2"
    create_file "file5" "$file5" "$game_dir/$dir1/$subdir3"
    create_file "file6" "$file6" "$game_dir/$dir1/$subdir3"
    create_file "file7" "$file7" "$game_dir/$dir2/$subdir4/$subsubdir1"
    create_file "file8" "$file8" "$game_dir/$dir2/$subdir4/$subsubdir2"
    create_file "file9" "$file9" "$game_dir/$dir2/$subdir5/$subsubdir3"
    create_file "file10" "$file10" "$game_dir/$dir2/$subdir5/$subsubdir4"
    create_file "file11" "$file11" "$game_dir/$dir2/$subdir6/$subsubdir5"
    create_file "file12" "$file12" "$game_dir/$dir2/$subdir6/$subsubdir6"

    # 追加分を記録
    set_append "dir3" "$dir3"
    set_append "file13" "$file13"
    set_append "file14" "$file14"
    set_append "subsubdir7" "$subsubdir7"

    # 問題文を作成
    instructions_rand="$game_dir/.metadata/instructions_rand"
    touch "$instructions_rand"
    echo "3. ディレクトリ・ファイルを扱う" >> "$instructions_rand"
    echo "以下の操作を順番に行ってください" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-1. $(get_origin_name 'file1')ファイルを$(get_origin_name 'subsubdir1')ディレクトリへコピーしなさい。" >> "$instructions_rand"
    echo "  コピー元ファイル：$(get_origin_path 'file1')" >> "$instructions_rand"
    echo "  コピー先ディレクトリ：$(get_origin_path 'subsubdir1')/" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-2. $(get_origin_name 'file7')ファイルを$(get_origin_name 'subsubdir4')ディレクトリへ移動させなさい。" >> "$instructions_rand"
    echo "  移動元ファイル：$(get_origin_path 'file7')" >> "$instructions_rand"
    echo "  移動先ディレクトリ：$(get_origin_path 'subsubdir4')/" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-3. $(get_origin_name 'subsubdir3')ディレクトリを丸ごと$(get_origin_name 'subsubdir6')ディレクトリの下へコピーしなさい。" >> "$instructions_rand"
    echo "  コピー元ディレクトリ：$(get_origin_path 'subsubdir3')/" >> "$instructions_rand"
    echo "  コピー先ディレクトリ：$(get_origin_path 'subsubdir6')/" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-4. $(get_origin_name 'subsubdir3')ディレクトリを$(get_append 'subsubdir7')という名前に変更しなさい。" >> "$instructions_rand"
    echo "  対象ディレクトリ：$(get_origin_path 'subsubdir3')/" >> "$instructions_rand"
    echo "  変更前のディレクトリ名：$(get_origin_name 'subsubdir3')" >> "$instructions_rand"
    echo "  変更後のディレクトリ名：$(get_append 'subsubdir7')" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-5. $(get_origin_name 'file8')ファイルを$(get_append 'file13')という名前に変更しなさい。" >> "$instructions_rand"
    echo "  対象ファイル：$(get_origin_path 'file8')" >> "$instructions_rand"
    echo "  変更前のファイル名：$(get_origin_name 'file8')" >> "$instructions_rand"
    echo "  変更後のファイル名：$(get_append 'file13')" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-6. 以下の2ファイルを削除しなさい。" >> "$instructions_rand"
    echo "  削除対象ファイル１つめ：$(get_origin_path 'file1')" >> "$instructions_rand"
    echo "  削除対象ファイル２つめ：$(get_origin_path 'file3')" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-7. $(get_append 'dir3')ディレクトリを作成しなさい。" >> "$instructions_rand"
    echo "  パス：${game_dir}/$(get_append 'dir3')/" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-8. $(get_origin_name 'subdir3')ディレクトリを3-7で作成したディレクトリの下に移動させなさい。" >> "$instructions_rand"
    echo "  移動対象のディレクトリ：$(get_origin_path 'subdir3')/" >> "$instructions_rand"
    echo "  移動先のディレクトリ：${game_dir}/$(get_append 'dir3')/" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-9. $(get_origin_name 'subsubdir5')ディレクトリを配下のファイルを含めて丸ごと削除しなさい。" >> "$instructions_rand"
    echo "  削除対象ディレクトリ：$(get_origin_path 'subsubdir5')" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-10. 3-8の$(get_origin_name 'subdir3')の下に$(get_append 'file14')という空ファイルを作成しなさい。" >> "$instructions_rand"
    echo "  対象ディレクトリ：${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')/" >> "$instructions_rand"
    echo "  対象ファイル：$(get_append 'file14')" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-11. $(get_origin_name 'subsubdir4')ディレクトリのパーミッションを711に変更しなさい。" >> "$instructions_rand"
    echo "パーミッションの変更は対象ディレクトリのみとし対象ディレクトリ配下のパーミッションは変えないものとします。" >> "$instructions_rand"
    echo "  対象ディレクトリ：$(get_origin_path 'subsubdir4')/" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-12. $(get_origin_name 'subsubdir6')ディレクトリ配下のパーミッションをすべて700に変更しなさい。" >> "$instructions_rand"
    echo "パーミッションの変更は対象ディレクトリも含むものとします。" >> "$instructions_rand"
    echo "  対象ディレクトリ：$(get_origin_path 'subsubdir6')/" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-13. $(get_origin_name 'file5')ファイルを$(get_origin_name 'file5').bakという名前でバックアップしなさい。" >> "$instructions_rand"
    echo "なお、バックアップファイルはバックアップ元ファイルのタイムスタンプを保持する形にしてください。" >> "$instructions_rand"
    echo "  バックアップ対象のファイル：${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')/$(get_origin_name 'file5')" >> "$instructions_rand"
    echo "  バックアップ後のファイル：${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')/$(get_origin_name 'file5').bak" >> "$instructions_rand"
    echo "  バックアップ条件：$(get_origin_name 'file5')と$(get_origin_name 'file5').bakのタイムスタンプが同じでなければいけない" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "3-14. $(get_origin_name 'file5')ファイルには以下の情報が含まれています。" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "X=1;Y=2;Z=3" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "Yの値を「999」に編集して保存しなさい。" >> "$instructions_rand"
    echo "  対象ファイル：${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')/$(get_origin_name 'file5')" >> "$instructions_rand"
    echo "" >> "$instructions_rand"

    ## 問題文に合わせてデフォルト情報を加工する
    # file5にのみデフォルト内容を追記
    echo "X=1;Y=2;Z=3" >> "$game_dir/$dir1/$subdir3/$file5"

    ## 問題文の解答を作成する
    # 存在チェック(directory)
    create_exists_dir "dir1" "$(get_origin_path 'dir1')"
    create_exists_dir "dir2" "$(get_origin_path 'dir2')"
    create_exists_dir "dir3" "${game_dir}/$(get_append 'dir3')"
    create_exists_dir "subdir1" "$(get_origin_path 'subdir1')"
    create_exists_dir "subdir2" "$(get_origin_path 'subdir2')"
    create_exists_dir "subdir3" "${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')"
    create_exists_dir "subdir4" "$(get_origin_path 'subdir4')"
    create_exists_dir "subdir5" "$(get_origin_path 'subdir5')"
    create_exists_dir "subdir6" "$(get_origin_path 'subdir6')"
    create_exists_dir "subsubdir1" "$(get_origin_path 'subsubdir1')"
    create_exists_dir "subsubdir2" "$(get_origin_path 'subsubdir2')"
    create_exists_dir "subsubdir7" "$(get_origin_path 'subdir5')/$(get_append 'subsubdir7')"
    create_exists_dir "subsubdir4" "$(get_origin_path 'subsubdir4')"
    create_exists_dir "subsubdir6" "$(get_origin_path 'subsubdir6')"
    create_exists_dir "subsubdir3" "$(get_origin_path 'subsubdir6')/$(get_origin_name 'subsubdir3')"

    # 非存在チェック(directory)
    create_not_exists_dir "subdir3" "$(get_origin_path 'subdir3')"
    create_not_exists_dir "subsubdir3" "$(get_origin_path 'subsubdir3')"
    create_not_exists_dir "subsubdir5" "$(get_origin_path 'subsubdir5')"

    # 存在チェック（file）
    create_exists_file "file1" "$(get_origin_path 'subsubdir1')/$(get_origin_name 'file1')"
    create_exists_file "file2" "$(get_origin_path 'file2')"
    create_exists_file "file4" "$(get_origin_path 'file4')"
    create_exists_file "file13" "$(get_origin_path 'subsubdir2')/$(get_append 'file13')"
    create_exists_file "file9_1" "$(get_origin_path 'subdir5')/$(get_append 'subsubdir7')/$(get_origin_name 'file9')"
    create_exists_file "file10" "$(get_origin_path 'file10')"
    create_exists_file "file7" "$(get_origin_path 'subsubdir4')/$(get_origin_name 'file7')"
    create_exists_file "file12" "$(get_origin_path 'file12')"
    create_exists_file "file9_2" "$(get_origin_path 'subsubdir6')/$(get_origin_name 'subsubdir3')/$(get_origin_name 'file9')"
    create_exists_file "file5" "${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')/$(get_origin_name 'file5')"
    create_exists_file "file5.bak" "${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')/$(get_origin_name 'file5').bak"
    create_exists_file "file6" "${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')/$(get_origin_name 'file6')"
    create_exists_file "file14" "${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')/$(get_append 'file14')"

    # 非存在チェック(file)
    create_not_exists_file "file1" "$(get_origin_path 'file1')"
    create_not_exists_file "file3" "$(get_origin_path 'file3')"
    create_not_exists_file "file5" "$(get_origin_path 'file5')"
    create_not_exists_file "file6" "$(get_origin_path 'file6')"
    create_not_exists_file "file7" "$(get_origin_path 'file7')"
    create_not_exists_file "file8" "$(get_origin_path 'file8')"
    create_not_exists_file "file9" "$(get_origin_path 'file9')"
    create_not_exists_file "file11" "$(get_origin_path 'file11')"

    # パーミッション(directory)
    create_permission_directory "subsubdir4" "$(get_origin_path 'subsubdir4')" "711"
    create_permission_directory "subsubdir6" "$(get_origin_path 'subsubdir6')" "700"
    create_permission_directory "subsubdir3" "$(get_origin_path 'subsubdir6')/$(get_origin_name 'subsubdir3')" "700"
    create_permission_directory "subsubdir3" "$(get_origin_path 'subsubdir6')/$(get_origin_name 'subsubdir3')/$(get_origin_name 'file9')" "700"

    # パーミッション(file)
    create_permission_file "file12" "$(get_origin_path 'file12')" "700"

    # タイムスタンプ
    create_timestamp "file5.bak" "${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')/$(get_origin_name 'file5').bak" "$(date -d @$(stat -c %Y $(get_origin_path 'file5')) +"%Y%m%d%H%M%S")"

    # 内容変更
    create_modify "file5" "${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')/$(get_origin_name 'file5')" "X=1;Y=999;Z=3"

    # 一時ファイルを削除
    rm "$temp_file"
}

generate_instructions() {
    instructions="$game_dir/.metadata/instructions"
    touch "$instructions"
    echo "--------------------------------------------------" >> "$instructions"
    echo "" >> "$instructions"
    echo "${game_dir}へ移動して以下の操作を行ってください" >> "$instructions"
    echo "" >> "$instructions"
    # ログ問題
    echo "1. ログを調べる" >> "$instructions"
    echo "${game_dir}/logsには3日分のアプリケーションログが格納されています。" >> "$instructions"
    echo "このログには「IPアドレス（v4）」「実行されたコマンド」「時刻」という3つの情報が含まれています。" >> "$instructions"
    IFS=',' read -ra LOGANSWER <<< "$(head -n 1 ${game_dir}/.metadata/target_log)"
    echo "${LOGANSWER[1]}において${LOGANSWER[2]}コマンドが実行された日付と時刻を特定しなさい。" >> "$instructions"
    echo "" >> "$instructions"
    echo "特定ができたらYYYYMMDDHHMISSの形式（年月日時分秒の14桁半角数字）にて回答を" >> "$instructions"
    echo "${game_dir}/answer/answer_log" >> "$instructions"
    echo "に記載しなさい。" >> "$instructions"
    echo "* answerディレクトリがなければ作成すること" >> "$instructions"
    echo "* answer_logファイルがなければ作成すること" >> "$instructions"
    echo "* answer_logに記載する内容はYYYYMMDDHHMISSのみであること" >> "$instructions"
    echo "* answer_logには改行を含めないこと" >> "$instructions"
    echo "" >> "$instructions"
    # sh問題
    echo "2. shを編集する" >> "$instructions"
    echo "${game_dir}/binには既存のshプログラムがいくつか格納されていますが、いずれも動く状態にありません。" >> "$instructions"
    echo "既存のshプログラムを動かすためにパーミッションを変更してください。" >> "$instructions"
    echo "ただし、あなたのみが実行できるようにするためにOwnerパーミッションのみを変更してください。" >> "$instructions"
    echo "Groupパーミッション、Otherパーミッションを変更してはいけません。" >> "$instructions"
    echo "" >> "$instructions"
    echo "既存のshプログラムが動くようになったら、それを参考にして" >> "$instructions"
    echo "${game_dir}/bin/c/proc.sh" >> "$instructions"
    echo "を自分で新規に作成してください。" >> "$instructions"
    echo "shプログラムの内容は標準出力に「ccc」と出力できる事のみが要件です。" >> "$instructions"
    echo "この新規作成したshプログラムのパーミッションは764とします。" >> "$instructions"
    echo "" >> "$instructions"
    # ファイル問題
    cat "${game_dir}/.metadata/instructions_rand" >> "$instructions"
    echo "" >> "$instructions"
    echo "この問題文は./practice_linux.sh instructionsで読み返せます" >> "$instructions"
    echo "" >> "$instructions"
    echo "--------------------------------------------------" >> "$instructions"
}

ready_game() {
    while true; do
        echo ""
        echo "ゲームを始める準備ができました"
        read -p "開始してよろしいですか？（Y/n）" yn
        case $yn in
            [Yy]* )
                break;;
            [Nn]* )
                rm -rf "$game_dir"
                rm -f practice_linux/practice_linux.lock
                echo "ゲーム開始をキャンセルしました。"
                exit;;
            * ) echo "Yまたはnを入力してください。";;
        esac
    done
}

start_game() {
    # 入力を待つ
    ready_game
    # .metadataの配下にstartファイルを作成
    touch "${game_dir}/.metadata/score/start"
}

display_instructions() {
    exit_if_not_lock
    path=$(get_lock)
    cat "${path}/.metadata/instructions"
}

continue_game() {
    echo ""
    echo "回答に誤りがあります。"
    echo ""
    echo "もしヒントが知りたい場合は"
    echo "./practice_linux.sh hint"
    echo "をどうぞ。"
    echo "（ただし確実にヒントが貰えるとは限りません）"
    exit
}

end_game() {
    echo "正解！"
    echo "おめでとうございます！"
    echo ""
    path=$(head -n 1 practice_linux/practice_linux.lock)
    touch "${path}/.metadata/score/end"
    number=$(echo -n "$path" | tail -c 3)
    display_score_base $number
    rm -f practice_linux/practice_linux.lock
}

generate_hint(){
    local message="$1"
    exit_if_not_lock
    cur=$(get_lock)
    
    if [ -e "${cur}/.metadata/hint" ]; then
        rm -f "${cur}/.metadata/hint"
    fi

    echo $message >> "${cur}/.metadata/hint"
}

display_hint() {
    exit_if_not_lock
    cur=$(get_lock)

    if [ -e "${cur}/.metadata/hint" ]; then
        cat "${cur}/.metadata/hint"
    else
        echo "ヒントはありません"
    fi
}

exit_if_not_games(){
    if [ ! -d "practice_linux/games" ]; then
        echo "ゲームがインストールされていません"
        echo "./practice_linux.sh startでゲームを開始してください"
        exit
    fi
}

exit_if_not_lock(){
    if [ ! -e "practice_linux/practice_linux.lock" ]; then
        echo "ゲームが開始されていません"
        echo "./practice_linux.sh startでゲームを開始してください"
        exit
    fi
}

get_lock(){
    echo "$(head -n 1 practice_linux/practice_linux.lock)"
}

validate_result_log(){
    local cur=$1

    if [ ! -d "${cur}/answer" ]; then
        generate_hint "問題文をよく読みましょう（問１）"
        continue_game
    fi

    if [ ! -e "${cur}/answer/answer_log" ]; then
        generate_hint "問題文をよく読みましょう（問１）"
        continue_game
    fi
    answer_log_user="$(head -n 1 ${cur}/answer/answer_log)"
    answer_log_correct="$(head -n 1 ${cur}/.metadata/target_log_answer)"

    if [ "${answer_log_user}" != "${answer_log_correct}" ]; then
        generate_hint "日付か時間が違うかもしれません（問１）"
        continue_game
    fi

}

validate_result_sh(){
    local cur=$1

    if [ ! -e "${cur}/bin/a/proc.sh" ]; then
        generate_hint "既存のファイルを消していませんか？（問２）"
        continue_game
    fi
    if [ ! -e "${cur}/bin/b/proc.sh" ]; then
        generate_hint "既存のファイルを消していませんか？（問２）"
        continue_game
    fi
    per_a=$(stat -c "%a" "${cur}/bin/a/proc.sh")
    if [ "$per_a" != "724" ]; then
        generate_hint "${cur}/bin/a/proc.shのパーミッションが適切でないようです。shは実行できる状態ですか？もしくは余計なパーミッションを変更していませんか？デフォルトのパーミッションは624でした。（問２）"
        continue_game
    fi
    per_b=$(stat -c "%a" "${cur}/bin/b/proc.sh")
    if [ "$per_b" != "742" ]; then
        generate_hint "${cur}/bin/b/proc.shのパーミッションが適切でないようです。shは実行できる状態ですか？もしくは余計なパーミッションを変更していませんか？デフォルトのパーミッションは642でした。（問２）"
        continue_game
    fi
    if [ ! -d "${cur}/bin/c" ]; then
        generate_hint "問題文をよく読みましょう（問２）"
        continue_game
    fi
    if [ ! -e "${cur}/bin/c/proc.sh" ]; then
        generate_hint "問題文をよく読みましょう（問２）"
        continue_game
    fi
    per_c=$(stat -c "%a" "${cur}/bin/c/proc.sh")
    if [ "$per_c" != "764" ]; then
        generate_hint "${cur}/bin/c/proc.shのパーミッションが適切でないようです。問題文をよく読みましょう（問２）"
        continue_game
    fi
    output_c=$(./${cur}/bin/c/proc.sh)
    if [ "$output_c" != "ccc" ]; then
        generate_hint "${cur}/bin/c/proc.shは動く状態にありますが出力が期待通りではないです（問２）"
        continue_game
    fi
}

validate_result_file(){
    local cur=$1

    # exists(dir)
    for file in "$cur/.metadata/rand/exists/dir"/*; do
        if [ -f "$file" ]; then
            exists_dir=$(head -n 1 ${file})
            if [ ! -d $exists_dir ]; then
                generate_hint "（問３）存在するべきディレクトリが存在していないようです:${exists_dir}"
                continue_game
            fi
        fi
    done

    # not exists(dir)
    for file in "$cur/.metadata/rand/not_exists/dir"/*; do
        if [ -f "$file" ]; then
            exists_dir=$(head -n 1 ${file})
            if [ -d $exists_dir ]; then
                generate_hint "（問３）余計なディレクトリが存在しているようです:${exists_dir}"
                continue_game
            fi
        fi
    done

    # exists(file)
    for file in "$cur/.metadata/rand/exists/file"/*; do
        if [ -f "$file" ]; then
            exists_file=$(head -n 1 ${file})
            if [ ! -e $exists_file ]; then
                generate_hint "（問３）存在するべきファイルが存在していないようです:${exists_file}"
                continue_game
            fi
        fi
    done

    # not exists(dir)
    for file in "$cur/.metadata/rand/not_exists/file"/*; do
        if [ -f "$file" ]; then
            exists_file=$(head -n 1 ${file})
            if [ -e $exists_file ]; then
                generate_hint "（問３）余計なファイルが存在しているようです:${exists_file}"
                continue_game
            fi
        fi
    done

    # permission(directory)
    for file in "$cur/.metadata/rand/permission/dir"/*; do
        if [ -f "$file" ]; then
            read -ra GET <<< "$(head -n 1 ${file})"
            if [ -d "${GET[0]}" ]; then
                permission=$(stat -c "%a" "${GET[0]}")
                if [ "$permission" != "${GET[1]}" ]; then
                    generate_hint "（問３）ディレクトリのパーミッションが違います:${GET[0]}"
                    continue_game
                fi
            fi
        fi
    done

    # permission(file)
    for file in "$cur/.metadata/rand/permission/file"/*; do
        if [ -f "$file" ]; then
            read -ra GET <<< "$(head -n 1 ${file})"
            if [ -e "${GET[0]}" ]; then
                permission=$(stat -c "%a" "${GET[0]}")
                if [ "$permission" != "${GET[1]}" ]; then
                    generate_hint "（問３）ファイルのパーミッションが違います:${GET[0]}"
                    continue_game
                fi
            fi
        fi
    done

    # timestamp(file)
    for file in "$cur/.metadata/rand/timestamp"/*; do
        if [ -f "$file" ]; then
            read -ra GET <<< "$(head -n 1 ${file})"
            if [ -e "${GET[0]}" ]; then
                timestamp=$(date -d @$(stat -c %Y ${GET[0]}) +"%Y%m%d%H%M%S")
                if [ "$timestamp" != "${GET[1]}" ]; then
                    generate_hint "（問３）ファイルのタイムスタンプが違います:${GET[0]}"
                    continue_game
                fi
            fi
        fi
    done

    # modify(contents of file)
    for file in "$cur/.metadata/rand/modify"/*; do
        if [ -f "$file" ]; then
            read -ra GET <<< "$(head -n 1 ${file})"
            if [ -e "${GET[0]}" ]; then
                contents=$(head -n 1 ${GET[0]})
                if [ "$contents" != "${GET[1]}" ]; then
                    generate_hint "（問３）ファイルの内容が違います:${GET[0]}"
                    continue_game
                fi
            fi
        fi
    done

}

validate_result_all() {
    exit_if_not_lock
    cur=$(get_lock)
    
    # ログ
    validate_result_log "${cur}"

    # sh
    validate_result_sh "${cur}"

    # ファイル
    validate_result_file "${cur}"

    end_game

}

display_score_list() {
    exit_if_not_games
    if [ -e "practice_linux/practice_linux.lock" ]; then
        processing=$(get_lock)
    fi
    exists=""
    for dir in "practice_linux/games"/*; do
        if [ -d "$dir" ]; then
            exists=$(basename "$dir")
            if [ "$processing" = "$dir" ];then
                suffix="　*実行中*"
            else
                suffix=""
            fi
            message=""
            dir_name=$(basename "$dir")
            
            # .metadataディレクトリの存在チェック
            if [ ! -d "$dir/.metadata" ]; then
                message="$dir_name: データ不正（.metadataなし）${suffix}"
            # scoreディレクトリの存在チェック
            elif [ ! -d "$dir/.metadata/score" ]; then
                message="$dir_name: データ不正（scoreなし）${suffix}"
            # startファイルの存在チェック
            elif [ ! -f "$dir/.metadata/score/start" ]; then
                message="$dir_name: データ不正（startなし）${suffix}"
            # endファイルの存在チェック
            elif [ ! -f "$dir/.metadata/score/end" ]; then
                message="$dir_name: 未完了${suffix}"
            else
                message="$dir_name: 完了${suffix}"
            fi

            echo $message
        fi
    done

    if [ "$exists" = "" ]; then
        echo "ゲームはありません"
    fi
}

display_score_latest(){
    exit_if_not_games
    score_exists=""
    for dir in $(find practice_linux/games/ -maxdepth 1 -type d | sort -r); do
        if [ -d "$dir" ]; then
            if [ -d "$dir/.metadata" ]; then
                if [ -d "$dir/.metadata/score" ]; then
                    if [ -e "$dir/.metadata/score/end" ]; then
                        score_exists=$(basename "$dir")
                        break
                    fi
                fi
            fi
        fi
    done

    if [ "$score_exists" = "" ]; then
        echo "完了しているゲームがありません"
    else
        display_score_base $score_exists
    fi
}

check_score(){
    local opt=$1
    exit_if_not_games

    # 引数が0-9で構成されていない場合
    if [[ ! $opt =~ ^[0-9]+$ ]]; then
        return 1
    fi

    # practice_linux/games/数字のディレクトリがない場合
    if [ ! -d "practice_linux/games/$opt" ]; then
        return 2
    fi

    return 0
}

delete_score(){
    local opt=$1
    while true; do
        echo "ゲーム「${opt}」を削除します。"
        read -p "削除してよろしいですか？（Y/n）" yn
        case $yn in
            [Yy]* )
                rm -rf practice_linux/games/${opt}
                echo "ゲーム「${opt}」を削除しました。"
                break;;
            [Nn]* )
                echo "削除をキャンセルしました。"
                exit;;
            * )
                echo "Yまたはnを入力してください。";;
        esac
    done
}

checkout_score(){
    local opt=$1
    if [ -e "practice_linux/games/$opt/.metadata/score/end" ]; then
        echo "そのゲームは完了済みのためチェックアウトできません"
        exit
    fi
    
    if [ -e "practice_linux/practice_linux.lock" ]; then
        rm -f "practice_linux/practice_linux.lock"
    fi

    echo "practice_linux/games/$opt" > practice_linux/practice_linux.lock
    echo "${opt}のチェックアウトが完了しました。"
    echo ""
    display_score_list
}

get_rank(){
    local hours=$1
    local minutes=$2
    local seconds=$3

    rank="F"
    if [ "$hours" -gt 2 ]; then
        rank="E"
    fi
    if [ "$hours" -gt 1 ]; then
        rank="D"
    fi
    if [ "$minutes" -gt 30 ]; then
        rank="C"
    fi
    if [ "$minutes" -lt 30 ]; then
        rank="B"
    fi
    if [ "$minutes" -lt 25 ]; then
        rank="A"
    fi
    if [ "$minutes" -lt 20 ]; then
        rank="S"
    fi
    if [ "$minutes" -lt 15 ]; then
        rank="SS"
    fi
    if [ "$minutes" -lt 10 ]; then
        rank="SSS"
    fi

    echo $rank
}

display_highest_score(){
    exit_if_not_games
    exists=""
    score=0
    for dir in "practice_linux/games"/*; do
        if [ -d "$dir" ]; then
            if [ -d "$dir/.metadata" ]; then
                if [ -d "$dir/.metadata/score" ]; then
                    if [ -e "$dir/.metadata/score/end" ]; then
                        start_timestamp=$(date -r "$dir/.metadata/score/start" +%s)
                        end_timestamp=$(date -r "$dir/.metadata/score/end" +%s)
                        diff_seconds=$((end_timestamp - start_timestamp))
                        if [ $score -eq 0 ]; then
                            score=$diff_seconds
                            exists=$(basename "$dir")
                        elif [ $score -gt $diff_seconds ]; then
                            score=$diff_seconds
                            exists=$(basename "$dir")
                        fi
                    fi
                fi
            fi
        fi
    done

    if [ "$exists" = "" ]; then
        echo "完了しているゲームがありません"
    else
        display_score_base $exists
    fi   
}

display_all_scores(){
    exit_if_not_games
    exists=""
    for dir in "practice_linux/games"/*; do
        if [ -d "$dir" ]; then
            if [ -d "$dir/.metadata" ]; then
                if [ -d "$dir/.metadata/score" ]; then
                    if [ -e "$dir/.metadata/score/end" ]; then
                        display_score_base $(basename "$dir")
                        exists=$(basename "$dir")
                    fi
                fi
            fi
        fi
    done

    if [ "$exists" = "" ]; then
        echo "完了しているゲームがありません"
    fi
}

display_score_base(){
    local number=$1
    # 本関数は各種チェック済みでコールされること

    game_dir_temp="practice_linux/games/$number/"

    if [ ! -e "${game_dir_temp}/.metadata/score/start" ]; then
        echo "データが不正です。"
        echo "${game_dir_temp}を手動で削除するか"
        echo "./practice_linux.sh format"
        echo "でゲームデータを初期化してください。"
        exit
    fi

    start_formatted=$(date -r "${game_dir_temp}/.metadata/score/start" +"%Y年%m月%d日 %H:%M:%S")

    if [ ! -e "${game_dir_temp}/.metadata/score/end" ]; then
        echo "ゲーム：${number}"
        echo "開始日時：${start_formatted}"    
        echo "このゲームは完了していないためスコアがありません。"
        echo "---------------------------"
        exit
    fi

    end_formatted=$(date -r "${game_dir_temp}/.metadata/score/end" +"%Y年%m月%d日 %H:%M:%S")

    echo "ゲーム　：${number}"
    echo "開始日時：${start_formatted}"
    echo "終了日時：${end_formatted}"

    start_timestamp=$(date -r "${game_dir_temp}/.metadata/score/start" +%s)
    end_timestamp=$(date -r "${game_dir_temp}/.metadata/score/end" +%s)

    diff_seconds=$((end_timestamp - start_timestamp))

    hours=$((diff_seconds / 3600))
    minutes=$(((diff_seconds % 3600) / 60 ))
    seconds=$((diff_seconds % 60))

    echo "タイム　：${hours}時間${minutes}分${seconds}秒"

    rank=$(get_rank "${hours}" "${minutes}" "${seconds}")
    echo "ランク　：${rank}"
    echo "---------------------------"
}

display_usage(){
    echo ""
    echo "Usage: ./practice_linux.sh {start|end|instructions|hint|score {list|all|<number>|highest|delete {<numbers>|}|}|checkout <numbers>|format|uninstall}"
    echo ""
    echo "Options:"
    echo "start        : Start new game. Only the first time the game is launched, the initial setup of the game is performed at the same time."
    echo "end          : Validate your answer. If you are right, the game will end and your score will be recoreded."
    echo "instructions : Display instructions."
    echo "hint         : Display hints."
    echo "score        : Show the last score. Can be combined with:"
    echo "                - list       : List all game numbers of score. With one of those, Use 'score <number>'"
    echo "                - all        : Show all scores."
    echo "                - <number>   : Show a specific score. You can get the list of numbers by 'score list'"
    echo "                - highest    : Show the highest score."
    echo "                - delete     : Delete all scores.(same as 'format') Can be combined with:"
    echo "                             - <number>   : Delete a specific score. You can get the list of numbers by 'score list'"
    echo "checkout <n> : Switch to uncompleted game with specific game number. You can get the list of numbers by 'score list'"
    echo "format       : Delete all scores and this app is going to be refreshed."
    echo "uninstall    : Delete all game datas."
    echo ""
    exit
}


# メインの処理
case $1 in
    start)
        # ゲームの初期化
        initialize_game
        # 問題生成
        echo ""
        echo "問題を生成しています…しばらくお待ちください"
        generate_directory_structure
        generate_logs
        generate_quiz_files
        generate_instructions
        echo "問題の生成が完了しました"
        # ゲーム開始
        start_game
        # 設問表示
        display_instructions
        ;;
    instructions)
        # 問題文を再表示
        display_instructions
        ;;
    hint)
        # ヒントを表示
        display_hint
        ;;
    end)
        # 回答を照合
        validate_result_all
        ;;
    format)
        # アプリの初期化
        initialize_app
        ;;
    uninstall)
        # アプリのアンインストール
        uninstall_app
        ;;
    score)
        case $2 in
            list)
                # スコアのリスト表示
                display_score_list
                ;;
            all)
                # すべてのスコアを表示
                display_all_scores
                ;;
            highest)
                # 最高のスコアを表示
                display_highest_score
                ;;
            delete)
                case $3 in
                    "")
                        # formatと同じ
                        initialize_app
                        ;;
                    *)
                        check_score $3
                        ret=$?
                        if [ $ret -ne 0 ]; then
                            # echo "ret: $ret"
                            display_usage
                        fi
                        delete_score $3
                        ;;
                esac
                ;;
            "")
                # 直前のスコアを表示
                display_score_latest
                ;;
            *)
                check_score $2
                ret=$?
                if [ $ret -ne 0 ]; then
                    # echo "ret: $ret"
                    display_usage
                fi
                display_score_base $2
                ;;
        esac
        ;;
    checkout)
        case $2 in
            "")
                display_usage
                ;;
            *)
                check_score $2
                ret=$?
                if [ $ret -ne 0 ]; then
                    # echo "ret: $ret"
                    display_usage
                fi
                checkout_score $2
                ;;
        esac
        ;;
    *)
        display_usage
        ;;
esac
