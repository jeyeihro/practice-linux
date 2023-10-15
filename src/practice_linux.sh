#!/bin/bash
# 
# Script for generating exercises for Linux beginners
# 
# author: jeyeihro
# https://github.com/jeyeihro/practice-linux
#

VERSION="1.0.2"

game_dir=""
declare -A already_generated
declare -a random_strings
temp_file=$(mktemp)

declare -A messages
messages=(
    ["Uninstall the game."]="ゲームをアンインストールします。"
    ["Are you sure you want to uninstall it?(Y/n)"]="アンインストールしてよろしいですか？（Y/n）"
    ["Game uninstalled."]="ゲームをアンインストールしました。"
    ["Canceled uninstallation."]="アンインストールをキャンセルしました。"
    ["Enter Y or n."]="Yまたはnを入力してください。"
    ["Now you can delete this sh file (practice_linux.sh) manually."]="あとはこのshファイル（practice_linux.sh）を手動で削除してください。"
    ["Thank you for your playing."]="お疲れさまでした。"
    ["Game not installed."]="ゲームがインストールされていません。"
    ["execute './practice_linux.sh start'"]="./practice_linux.sh startでゲームを開始してください。"
    ["This Application datas is going to be initiallized."]="アプリケーションデータを初期化します。"
    ["The app directory already exists."]="既にアプリのディレクトリが存在します。"
    ["All scores will be deleted."]="スコアはすべて削除されます。"
    ["Are you sure you want to delete it?(Y/n)"]="削除してよろしいですか？（Y/n）"
    ["The app directory has been deleted."]="ディレクトリを削除しました。"
    ["Canceled."]="キャンセルしました。"
    ["initiallizing...."]="初期化しています。"
    ["Initialization completed."]="初期化が完了しました。"
    ["Game records are reaching their limits."]="ゲームの記録が限界に達しています。"
    ["to initialize all game data, or"]="を実行してすべてのゲームデータを初期化する、もしくは"
    ["to delete unnecessary game data."]="を実行して不要なゲームデータを削除してください。"
    ["Generating exercises... please wait a moment"]="問題を生成しています…しばらくお待ちください"
    ["Generation completed."]="問題の生成が完了しました"
    ["3. Dealing with directories and files"]="3. ディレクトリ・ファイルを扱う"
    ["Perform the following operations in order."]="以下の操作を順番に行ってください"
    ["3-1. copy file {} to directory {}."]="3-1. {}ファイルを{}ディレクトリへコピーしなさい。"
    ["  copy source file: {}"]="  コピー元ファイル: {}"
    ["  copy destination directory: {}"]="  コピー先ディレクトリ: {}"
    ["3-2. move file {} to directory {}."]="3-2. {}ファイルを{}ディレクトリへ移動させなさい。"
    ["  move source file: {}"]="  移動元ファイル: {}"
    ["  move destination directory: {}"]="  移動先ディレクトリ: {}"
    ["3-3. copy the entire directory {} under directory {}."]="3-3. {}ディレクトリを丸ごと{}ディレクトリの下へコピーしなさい。"
    ["  copy source directory: {}"]="  コピー元ディレクトリ: {}"
    ["3-4. rename directory {} to {}."]="3-4. {}ディレクトリを{}という名前に変更しなさい。"
    ["  target directory: {}"]="  対象ディレクトリ: {}"
    ["  directory name before change: {}"]="  変更前のディレクトリ名: {}"
    ["  directory name after change: {}"]="  変更前のディレクトリ名: {}"
    ["3-5. rename file {} to {}."]="3-5. {}ファイルを{}という名前に変更しなさい。"
    ["  target file: {}"]="  対象ファイル: {}"
    ["  file name before change: {}"]="  変更前のファイル名: {}"
    ["  file name after change: {}"]="  変更前のファイル名: {}"
    ["3-6. delete the following two files."]="3-6. 以下の2ファイルを削除しなさい。"
    ["  1st file to be deleted: {}"]="  削除対象ファイル１つめ: {}"
    ["  2nd file to be deleted: {}"]="  削除対象ファイル２つめ: {}"
    ["3-7. create {} directory."]="3-7. {}ディレクトリを作成しなさい。"
    ["  path: {}/{}/"]="  パス: {}/{}/"
    ["3-8. move directory {} under the directory created in 3-7."]="3-8. {}ディレクトリを3-7で作成したディレクトリの下に移動させなさい。"
    ["  directory to be moved: {}/"]="  移動対象のディレクトリ: {}/"
    ["  destination directory: {}/{}/"]="  移動先のディレクトリ: {}/{}/"
    ["3-9. delete the entire {} directory including all its files."]="3-9. {}ディレクトリを配下のファイルを含めて丸ごと削除しなさい。"
    ["  directory to be deleted: {}"]="  削除対象ディレクトリ: {}"
    ["3-10. Under 3-8's {}, create an empty file named {}."]="3-10. 3-8の{}の下に{}という空ファイルを作成しなさい。"
    ["  target directory: {}/{}/{}/"]="  対象ディレクトリ: {}/{}/{}/"
    ["3-11. Change the permissions of the {} directory to 711."]="3-11. {}ディレクトリのパーミッションを711に変更しなさい。"
    ["Only change the permissions of the target directory and do not change the permissions of anything inside it."]="パーミッションの変更は対象ディレクトリのみとし対象ディレクトリ配下のパーミッションは変えないものとします。"
    ["  target directory: {}/"]=" 対象ディレクトリ: {}/"
    ["3-12. Change all the permissions under the {} directory to 700."]="3-12. {}ディレクトリ配下のパーミッションをすべて700に変更しなさい。"
    ["The permission change also includes the target directory."]="パーミッションの変更は対象ディレクトリも含むものとします。"
    ["3-13. Backup the {} file as {}.bak."]="3-13. {}ファイルを{}.bakという名前でバックアップしなさい。"
    ["Additionally, please ensure the backup file retains the timestamp of the original file."]="なお、バックアップファイルはバックアップ元ファイルのタイムスタンプを保持する形にしてください。"
    ["  target file for backup: {}/{}/{}/{}"]="  バックアップ対象のファイル: {}/{}/{}/{}"
    ["  backup file after backup: {}/{}/{}/{}.bak"]="  バックアップ後のファイル: {}/{}/{}/{}.bak"
    ["  backup condition: {} and {}.bak timestamps must be the same."]="  バックアップ条件: {}と{}.bakのタイムスタンプが同じでなければいけない"
    ["3-14. The {} file contains the following information."]="3-14. {}ファイルには以下の情報が含まれています。"
    ["Edit the value of Y to '999' and save."]="Yの値を「999」に編集して保存しなさい。"
    ["  target file: {}/{}/{}/{}"]="  対象ファイル: {}/{}/{}/{}"
    ["Move to {} and perform the following operations."]="{}へ移動して以下の操作を行ってください"
    ["1. Examine the logs."]="1. ログを調べる"
    ["The {} contains three days' worth of application logs."]="{}には3日分のアプリケーションログが格納されています。"
    ["This log contains three pieces of information: 'IP address (v4)', 'executed command', and 'timestamp'."]="このログには「IPアドレス（v4）」「実行されたコマンド」「時刻」という3つの情報が含まれています。"
    ["Identify the date and time when the {} command was executed in {}."]="{}コマンドが{}において実行された日付と時刻を特定しなさい。"
    ["Once identified, please write your answer below in the YYYYMMDDHHMISS format (14-digit half-width number representing year, month, day, hour, minute, and second)."]="特定ができたらYYYYMMDDHHMISSの形式（年月日時分秒の14桁半角数字）にて回答を以下に記載しなさい。"
    ["* If the answer directory does not exist, create it."]="* answerディレクトリがなければ作成すること"
    ["* If the answer_log file does not exist, create it."]="* answer_logファイルがなければ作成すること"
    ["* The content written in answer_log should only be YYYYMMDDHHMISS."]="* answer_logに記載する内容はYYYYMMDDHHMISSのみであること"
    ["* Do not include line breaks in answer_log."]="* answer_logには改行を含めないこと"
    ["2. Edit the sh."]="2. shを編集する"
    ["There are several existing sh programs in {}, but none of them are operational."]="{}には既存のshプログラムがいくつか格納されていますが、いずれも動く状態にありません。"
    ["Change the permissions to make the existing sh programs operational."]="既存のshプログラムを動かすためにパーミッションを変更してください。"
    ["However, only change the Owner permissions so that only you can execute it."]="ただし、あなたのみが実行できるようにするためにOwnerパーミッションのみを変更してください。"
    ["Do not change the Group permissions or Other permissions."]="Groupパーミッション、Otherパーミッションを変更してはいけません。"
    ["Once the existing sh programs are operational, use them as a reference to create the following sh script file on your own."]="既存のshプログラムが動くようになったら、それを参考にして以下のshスクリプトファイルを自分で新規に作成してください。"
    ["The only requirement for the sh program is that it can output 'ccc' to standard output."]="shプログラムの内容は標準出力に「ccc」と出力できる事のみが要件です。"
    ["Set the permissions of this newly created sh script file to 764."]="この新規作成したshスクリプトファイルのパーミッションは764とします。"
    ["You can review this question by running ./practice_linux.sh instructions."]="この問題文は./practice_linux.sh instructionsで読み返せます"
    ["The game is now ready to begin."]="ゲームを始める準備ができました"
    ["Are you ready to start? (Y/n)"]="開始してよろしいですか？（Y/n）"
    ["The game start was cancelled."]="ゲーム開始をキャンセルしました。"
    ["Please enter Y or n."]="Yまたはnを入力してください。"
    ["There is an error in your answer."]="回答に誤りがあります。"
    ["If you want a hint, please refer below."]="もしヒントが知りたい場合は以下をどうぞ"
    ["(However, it's not guaranteed that you'll always receive a hint.)"]="（ただし確実にヒントが貰えるとは限りません）"
    ["Correct!"]="正解！"
    ["Congratulations!"]="おめでとうございます！"
    ["There is no hint."]="ヒントはありません"
    ["The game is not installed."]="ゲームがインストールされていません"
    ["Please start the game with ./practice_linux.sh start."]="./practice_linux.sh startでゲームを開始してください"
    ["The game has not been started."]="ゲームが開始されていません"
    ["Please read the question carefully (Question {})."]="問題文をよく読みましょう（問{}）"
    ["The date or time might be incorrect (Question 1)."]="日付か時間が違うかもしれません（問１）"
    ["Did you delete any existing files? (Question 2)"]="既存のファイルを消していませんか？（問２）"
    ["Is the permission of {} appropriate? Is the sh executable? Or did you change any unnecessary permissions? The default permission was {}. (Question 2)"]="{}のパーミッションが適切でないようです。shは実行できる状態ですか？もしくは余計なパーミッションを変更していませんか？デフォルトのパーミッションは{}でした。（問２）"
    ["The permission of {} seems not appropriate. (Question {})"]="{}のパーミッションが適切でないようです。（問{}）"
    ["{} is operational, but the output is not as expected. (Question 2)"]="{}は動く状態にありますが出力が期待通りではないです（問２）"
    ["(Question 3) The expected directory does not seem to exist: {}"]="（問３）存在するべきディレクトリが存在していないようです: {}"
    ["(Question 3) The unexpected directory seems to exist: {}"]="（問３）余計なディレクトリが存在しているようです: {}"
    ["(Question 3) The expected file does not seem to exist: {}"]="（問３）存在するべきファイルが存在していないようです: {}"
    ["(Question 3) The unexpected file seems to exist: {}"]="（問３）余計なファイルが存在しているようです: {}"
    ["(Question 3) The timestamp of {} seems not appropriate."]="（問３）{}のタイムスタンプが適切でないようです"
    ["(Question 3) The contents of {} seems not appropriate."]="（問３）{}のファイル内容が適切でないようです"
    ["  *in progress*"]="  *実行中*"
    ["No games exists"]="ゲームはありません"
    ["Illegal data(.metadata not exists)"]="データ不正（.metadataなし）"
    ["Illegal data(score not exists)"]="データ不正（scoreなし）"
    ["Illegal data(start not exists)"]="データ不正（startなし）"
    ["Incomplete"]="未完了"
    ["Completed"]="完了"
    ["No games have been completed"]="完了しているゲームがありません"
    ["Game [{}] is going to be deleted."]="ゲーム「{}」を削除します。"
    ["Are you sure you want to delete it?(Y/n)"]="削除してよろしいですか？（Y/n）"
    ["{} has been deleted"]="ゲーム「{}」を削除しました。"
    ["Cancelled deletion"]="削除をキャンセルしました。"
    ["The game has been completed and cannot be checked out"]="そのゲームは完了済みのためチェックアウトできません"
    ["[{}] checkout has been completed."]="[{}]のチェックアウトが完了しました。"
    ["Data is invalid."]="データが不正です。"
    ["Manually delete {}, or"]="{}を手動で削除する、もしくは"
    ["Initialize the game data by executing ./practice_linux.sh format."]="./practice_linux.sh formatを実行してゲームデータを初期化してください。"
    ["Game          : {}"]="ゲーム      : {}"
    ["Player        : {}"]="回答者      : {}"
    ["Locale        : {}"]="言語　      : {}"
    ["Start datetime: {}"]="開始日時    : {}"
    ["End   datetime: {}"]="終了日時    : {}"
    ["Required Time : {} hours {} minutes {} seconds"]="タイム      : {}時間{}分{}秒"
    ["Rank          : {}"]="ランク      : {}"
    ["This game has not been completed and therefore has no score."]="このゲームは完了していないためスコアがありません。"
    ["*** Running in debug mode ***"]="*** ただいまデバッグモードで作動中です ***"
    ["*** Done with debug mode ***"]="*** このゲームはデバッグモードで行われました ***"
    ["Japanese"]="日本語"
    ["English"]="英語"
    ["An irregularity with the game has been detected."]="ゲームの不正が検知されました。"
)

localize() {
    local input_msg="$1"
    ret=""

    if [ ! -d "practice_linux" ]; then
        ret=$input_msg
    elif [ ! -d "practice_linux/.ini" ]; then
        ret=$input_msg
    elif [ -e "practice_linux/.ini/locale_ja" ]; then
        local localized_msg=$(awk -F'=' -v msg="\"$input_msg\"" '$1 == msg { print $2 }' practice_linux/.ini/messages)
        ret=${localized_msg//\"/}
    else
        ret=$input_msg
    fi
    echo "${ret}"
}

display_locale(){
    exit_if_not_games

    if [ -e "practice_linux/.ini/locale_ja" ]; then
        echo "現在のロケールは日本語です。"
    else
        echo "The current locale is English."
    fi
}

change_locale_en(){
    exit_if_not_games

    if [ -e "practice_linux/.ini/locale_ja" ]; then
        rm -f "practice_linux/.ini/locale_ja"
    fi
    echo "Changed current locale to English."
}

change_locale_ja(){
    exit_if_not_games

    echo -n > "practice_linux/.ini/locale_ja"
    echo "ロケールを日本語に変更しました。"
}

stock(){
    # logs is a reserved word
    already_generated["logs"]=1
    random_strings+="logs"

    while [ ${#random_strings[@]} -lt 31 ]; do
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
        echo "${random_strings[-1]}"
        echo "${random_strings[@]:0:${#random_strings[@]}-1}" > "$temp_file"
    else
        echo "Error: No more strings left!"
        exit 1
    fi
}

uninstall_app() {
    exit_if_not_games
    while true; do
        echo "$(localize "Uninstall the game.")"
        read -p "$(localize "Are you sure you want to uninstall it?(Y/n)")" yn
        case $yn in
            [Yy]* )
                echo ""
                echo "$(localize "Game uninstalled.")"
                break;;
            [Nn]* )
                echo "$(localize "Canceled uninstallation.")"
                exit;;
            * ) 
                echo "$(localize "Enter Y or n.")"
                ;;
        esac
    done

    echo "$(localize "Now you can delete this sh file (practice_linux.sh) manually.")"
    echo "$(localize "Thank you for your playing.")"

    rm -rf practice_linux
}

select_locale(){
    if [ ! -d "practice_linux/.ini" ]; then
        echo "Game not installed."
        echo "execute './practice_linux.sh start'"
        exit
    fi

    while true; do
        echo ""
        echo "Choose your language."
        echo "1. English  2.日本語"
        echo ""
        read -p "which?" lang
        case $lang in
            1)
                break
                ;;
            2)
                touch "practice_linux/.ini/locale_ja"
                break
                ;;
            *)
                echo ""
                echo "illegal number."
                echo ""
                ;;
        esac
    done
}

create_messages(){
    messages_path="practice_linux/.ini/messages"
    echo -n > "${messages_path}"

    for key in "${!messages[@]}"; do
        echo "\"$key\"=\"${messages[$key]}\"" >> "${messages_path}"
    done
}

initialize_app() {
    echo "$(localize "This Application datas is going to be initiallized.")"
    echo ""
    if [ -d "practice_linux" ]; then
        while true; do
            echo "$(localize "The app directory already exists.")"
            echo "$(localize "All scores will be deleted.")"
            echo ""
            read -p "$(localize "Are you sure you want to delete it?(Y/n)")" yn
            case $yn in
                [Yy]* )
                    echo "$(localize "The app directory has been deleted.")"
                    break;;
                [Nn]* )
                    echo "$(localize "Canceled.")"
                    exit;;
                * ) 
                    echo ""
                    echo "$(localize "Enter Y or n.")"
                    echo "";;
            esac
        done

        rm -rf practice_linux
    else
        echo "$(localize "initiallizing....")"
    fi

    mkdir -p practice_linux/games
    mkdir -p practice_linux/.ini
    
    create_messages

    echo "$(localize "Initialization completed.")"
}

initialize_game() {
    if [ ! -d "practice_linux" ]; then
        echo "Welcome to practice_linux!!(${VERSION})"
        initialize_app
        select_locale
    fi

    games_root="practice_linux/games"

    # Get the maximum number of directory names under the games directory that are numeric only
    max_game=$(ls "$games_root" | grep '^[0-9]*$' | sort -n | tail -1)

    if [ -z "$max_game" ]; then
        max_game=0
    fi

    # If the max value directory exists (even if there are omissions under it), the game ends.
    if [ "$max_game" -eq "999" ]; then
        echo "$(localize "Game records are reaching their limits.")"
        echo ""
        echo "./practice_linux.sh format"
        echo "$(localize "to initialize all game data, or")"
        echo ""
        echo "./practice_linux.sh score delete <number>"
        echo "$(localize "to delete unnecessary game data.")"
        exit
    fi

    next_game=$(printf "%03d" $((10#$max_game + 1)))
    mkdir "${games_root}/${next_game}"
    game_dir="${games_root}/${next_game}"
    echo $game_dir > practice_linux/practice_linux.lock
    mkdir "${game_dir}/.metadata"
    local current_datetime=$(date "+%Y%m%d%H%M%S")
    local username=$(whoami)
    echo "$current_datetime" > ${game_dir}/.metadata/created_at
    echo "$username" > ${game_dir}/.metadata/created_by

    if [ -e practice_linux/.ini/locale_ja ]; then
        echo "Japanese" > ${game_dir}/.metadata/locale
    else
        echo "English" > ${game_dir}/.metadata/locale
    fi
}

generate_directory_structure() {
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
    local NUM_IP=20
    local NUM_TRG=30
    local NUM_LINES_PER_FILE=$((NUM_IP*NUM_TRG/3))
    declare -a ip_addresses
    declare -a log_strings
    declare -a log_entries

    for i in $(seq 1 $NUM_IP); do
        local ip="$(shuf -i 10-254 -n 1).$(shuf -i 10-254 -n 1).$(shuf -i 10-254 -n 1).$i"
        ip_addresses+=("$ip")
    done

    for i in $(seq 1 $NUM_TRG); do
        log_strings+=("hoge$(printf "%03d" $i)")
    done

    for ip in "${ip_addresses[@]}"; do
        for log_string in "${log_strings[@]}"; do
            log_entries+=("$ip $log_string")
        done
    done

    IFS=$'\n' read -d '' -r -a shuffled_logs < <(printf "%s\n" "${log_entries[@]}" | shuf && printf '\0')

    local yesterday=$(date --date="1 day ago" +%Y%m%d)
    local day_before_yesterday=$(date --date="2 days ago" +%Y%m%d)
    local two_days_before=$(date --date="3 days ago" +%Y%m%d)

    for day in $two_days_before $day_before_yesterday $yesterday; do
        local filename="${game_dir}/logs/app.log.$day"
        
        [ -f $filename ] && rm $filename

        local seconds=0

        for i in $(seq 1 $NUM_LINES_PER_FILE); do
            local time=$(printf "%02d:%02d:%02d" $(($seconds / 3600)) $(($seconds % 3600 / 60)) $(($seconds % 60)))
            echo "${shuffled_logs[$i]} $time" >> $filename
            seconds=$((seconds + 4))
        done

        shuffled_logs=("${shuffled_logs[@]:$NUM_LINES_PER_FILE}")
    done

    local selected_entry=$(
    for file in "${game_dir}/logs/app.log.$two_days_before}" "${game_dir}/logs/app.log.$day_before_yesterday" "${game_dir}/logs/app.log.$yesterday"; do
        [ -f "$file" ] && awk '{print FILENAME " " $0}' "$file"
    done | shuf -n 1
    )

    part1=$(echo "$selected_entry" | awk '{print substr($1,length($1)-7,8)}')

    part2=$(echo "$selected_entry" | awk '{gsub(":","",$4); print $4}')

    result="${part1}${part2}"

    echo "$result" > "${game_dir}/.metadata/target_log_answer"

    echo "${selected_entry// /,}" > "${game_dir}/.metadata/target_log"    
}

create_directory() {
    local resourcekey=$1
    local resourcename=$2
    local dirpath=$3

    mkdir -p "$dirpath"

    set_origin "$resourcekey" "$resourcename" "$dirpath"
}

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

bind_str(){
    local template="$1"
    shift

    while [ "$#" -gt 0 ]; do
        template=${template/\{\}/$1}
        shift
    done

    echo "$template"
}

generate_quiz_files() {
    stock
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

    set_append "dir3" "$dir3"
    set_append "file13" "$file13"
    set_append "file14" "$file14"
    set_append "subsubdir7" "$subsubdir7"

    # Questions about files and directories
    instructions_rand="$game_dir/.metadata/instructions_rand"
    touch "$instructions_rand"
    echo "$(localize "3. Dealing with directories and files")" >> "$instructions_rand"
    echo "$(localize "Perform the following operations in order.")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-1. copy file {} to directory {}.")" "$(get_origin_name 'file1')" "$(get_origin_name 'subsubdir1')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  copy source file: {}")" "$(get_origin_path 'file1')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  copy destination directory: {}")" "$(get_origin_path 'subsubdir1')/")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-2. move file {} to directory {}.")" "$(get_origin_name 'file7')" "$(get_origin_name 'subsubdir4')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  move source file: {}")" "$(get_origin_path 'file7')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  move destination directory: {}")" "$(get_origin_path 'subsubdir4')/")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-3. copy the entire directory {} under directory {}.")" "$(get_origin_name 'subsubdir3')" "$(get_origin_name 'subsubdir6')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  copy source directory: {}")" "$(get_origin_path 'subsubdir3')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  copy destination directory: {}")" "$(get_origin_path 'subsubdir6')/")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-4. rename directory {} to {}.")" "$(get_origin_name 'subsubdir3')" "$(get_append 'subsubdir7')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  target directory: {}")" "$(get_origin_path 'subsubdir3')/")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  directory name before change: {}")" "$(get_origin_name 'subsubdir3')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  directory name after change: {}")" "$(get_append 'subsubdir7')")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-5. rename file {} to {}.")" "$(get_origin_name 'file8')" "$(get_append 'file13')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  target file: {}")" "$(get_origin_path 'file8')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  file name before change: {}")" "$(get_origin_name 'file8')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  file name after change: {}")" "$(get_append 'file13')")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(localize "3-6. delete the following two files.")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  1st file to be deleted: {}")" "$(get_origin_path 'file1')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  2nd file to be deleted: {}")" "$(get_origin_path 'file3')")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-7. create {} directory.")" "$(get_append 'dir3')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  path: {}/{}/")" "${game_dir}" "$(get_append 'dir3')")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-8. move directory {} under the directory created in 3-7.")" "$(get_origin_name 'subdir3')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  directory to be moved: {}/")" "$(get_origin_path 'subdir3')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  destination directory: {}/{}/")" "${game_dir}" "$(get_append 'dir3')")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-9. delete the entire {} directory including all its files.")" "$(get_origin_name 'subsubdir5')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  directory to be deleted: {}")" "$(get_origin_path 'subsubdir5')")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-10. Under 3-8's {}, create an empty file named {}.")" "$(get_origin_name 'subdir3')" "$(get_append 'file14')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  target directory: {}/{}/{}/")" "${game_dir}" "$(get_append 'dir3')" "$(get_origin_name 'subdir3')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  target file: {}")" "$(get_append 'file14')")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-11. Change the permissions of the {} directory to 711.")" "$(get_origin_name 'subsubdir4')")" >> "$instructions_rand"
    echo "$(localize "Only change the permissions of the target directory and do not change the permissions of anything inside it.")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  target directory: {}/")" "$(get_origin_path 'subsubdir4')")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-12. Change all the permissions under the {} directory to 700.")" "$(get_origin_name 'subsubdir6')")" >> "$instructions_rand"
    echo "$(localize "The permission change also includes the target directory.")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  target directory: {}/")" "$(get_origin_path 'subsubdir6')")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-13. Backup the {} file as {}.bak.")" "$(get_origin_name 'file5')" "$(get_origin_name 'file5')")" >> "$instructions_rand"
    echo "$(localize "Additionally, please ensure the backup file retains the timestamp of the original file.")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  target file for backup: {}/{}/{}/{}")" "${game_dir}" "$(get_append 'dir3')" "$(get_origin_name 'subdir3')" "$(get_origin_name 'file5')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  backup file after backup: {}/{}/{}/{}.bak")" "${game_dir}" "$(get_append 'dir3')" "$(get_origin_name 'subdir3')" "$(get_origin_name 'file5')")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  backup condition: {} and {}.bak timestamps must be the same.")" "$(get_origin_name 'file5')" "$(get_origin_name 'file5')")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(bind_str "$(localize "3-14. The {} file contains the following information.")" "$(get_origin_name 'file5')")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "X=1;Y=2;Z=3" >> "$instructions_rand"
    echo "" >> "$instructions_rand"
    echo "$(localize "Edit the value of Y to '999' and save.")" >> "$instructions_rand"
    echo "$(bind_str "$(localize "  target file: {}/{}/{}/{}")" "${game_dir}" "$(get_append 'dir3')" "$(get_origin_name 'subdir3')" "$(get_origin_name 'file5')")" >> "$instructions_rand"
    echo "" >> "$instructions_rand"

    ## Processing default information to fit the practice statement
    # Add default contents to file5 only
    echo "X=1;Y=2;Z=3" >> "$game_dir/$dir1/$subdir3/$file5"

    ## Prepare answers to the practice statement.
    # Existence check (directory)
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

    # Non-existence check (directory)
    create_not_exists_dir "subdir3" "$(get_origin_path 'subdir3')"
    create_not_exists_dir "subsubdir3" "$(get_origin_path 'subsubdir3')"
    create_not_exists_dir "subsubdir5" "$(get_origin_path 'subsubdir5')"

    # Existence check (file)
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

    # Non-existence check (file)
    create_not_exists_file "file1" "$(get_origin_path 'file1')"
    create_not_exists_file "file3" "$(get_origin_path 'file3')"
    create_not_exists_file "file5" "$(get_origin_path 'file5')"
    create_not_exists_file "file6" "$(get_origin_path 'file6')"
    create_not_exists_file "file7" "$(get_origin_path 'file7')"
    create_not_exists_file "file8" "$(get_origin_path 'file8')"
    create_not_exists_file "file9" "$(get_origin_path 'file9')"
    create_not_exists_file "file11" "$(get_origin_path 'file11')"

    # Permission check (directory)
    create_permission_directory "subsubdir4" "$(get_origin_path 'subsubdir4')" "711"
    create_permission_directory "subsubdir6" "$(get_origin_path 'subsubdir6')" "700"
    create_permission_directory "subsubdir3" "$(get_origin_path 'subsubdir6')/$(get_origin_name 'subsubdir3')" "700"
    create_permission_directory "subsubdir3" "$(get_origin_path 'subsubdir6')/$(get_origin_name 'subsubdir3')/$(get_origin_name 'file9')" "700"

    # Permission check (file)
    create_permission_file "file12" "$(get_origin_path 'file12')" "700"

    # Timesamp check
    create_timestamp "file5.bak" "${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')/$(get_origin_name 'file5').bak" "$(date -d @$(stat -c %Y $(get_origin_path 'file5')) +"%Y%m%d%H%M%S")"

    # Content Change check
    create_modify "file5" "${game_dir}/$(get_append 'dir3')/$(get_origin_name 'subdir3')/$(get_origin_name 'file5')" "X=1;Y=999;Z=3"

    # Delete temporary files
    rm "$temp_file"
}

generate_instructions() {
    instructions="$game_dir/.metadata/instructions"
    touch "$instructions"
    echo "--------------------------------------------------" >> "$instructions"
    echo "" >> "$instructions"
    echo "$(bind_str "$(localize "Move to {} and perform the following operations.")" "${game_dir}")" >> "$instructions"
    echo "" >> "$instructions"
    # Questions about logs
    echo "$(localize "1. Examine the logs.")" >> "$instructions"
    echo "$(bind_str "$(localize "The {} contains three days' worth of application logs.")" "${game_dir}/logs")" >> "$instructions"
    echo "$(localize "This log contains three pieces of information: 'IP address (v4)', 'executed command', and 'timestamp'.")" >> "$instructions"
    IFS=',' read -ra LOGANSWER <<< "$(head -n 1 ${game_dir}/.metadata/target_log)"
    echo "$(bind_str "$(localize "Identify the date and time when the {} command was executed in {}.")" "${LOGANSWER[2]}" "${LOGANSWER[1]}")" >> "$instructions"
    echo "" >> "$instructions"
    echo "$(localize "Once identified, please write your answer below in the YYYYMMDDHHMISS format (14-digit half-width number representing year, month, day, hour, minute, and second).")" >> "$instructions"
    echo "${game_dir}/answer/answer_log" >> "$instructions"
    echo "$(localize "* If the answer directory does not exist, create it.")" >> "$instructions"
    echo "$(localize "* If the answer_log file does not exist, create it.")" >> "$instructions"
    echo "$(localize "* The content written in answer_log should only be YYYYMMDDHHMISS.")" >> "$instructions"
    echo "$(localize "* Do not include line breaks in answer_log.")" >> "$instructions"
    echo "" >> "$instructions"
    # Questions about sh
    echo "$(localize "2. Edit the sh.")" >> "$instructions"
    echo "$(bind_str "$(localize "There are several existing sh programs in {}, but none of them are operational.")" "${game_dir}/bin")" >> "$instructions"
    echo "$(localize "Change the permissions to make the existing sh programs operational.")" >> "$instructions"
    echo "$(localize "However, only change the Owner permissions so that only you can execute it.")" >> "$instructions"
    echo "$(localize "Do not change the Group permissions or Other permissions.")" >> "$instructions"
    echo "" >> "$instructions"
    echo "$(localize "Once the existing sh programs are operational, use them as a reference to create the following sh script file on your own.")" >> "$instructions"
    echo "${game_dir}/bin/c/proc.sh" >> "$instructions"
    echo "$(localize "The only requirement for the sh program is that it can output 'ccc' to standard output.")" >> "$instructions"
    echo "$(localize "Set the permissions of this newly created sh script file to 764.")" >> "$instructions"
    echo "" >> "$instructions"
    # Questions about files and directories(prepared)
    cat "${game_dir}/.metadata/instructions_rand" >> "$instructions"
    echo "" >> "$instructions"
    echo "$(localize "You can review this question by running ./practice_linux.sh instructions.")" >> "$instructions"
    echo "" >> "$instructions"
    echo "--------------------------------------------------" >> "$instructions"
}

ready_game() {
    while true; do
        echo ""
        echo "$(localize "The game is now ready to begin.")"
        read -p "$(localize "Are you ready to start? (Y/n)")" yn
        case $yn in
            [Yy]* )
                break
                ;;
            [Nn]* )
                echo "$(localize "The game start was cancelled.")"
                rm -rf "$game_dir"
                rm -f practice_linux/practice_linux.lock
                exit
                ;;
            * )
                echo "$(localize "Please enter Y or n.")"
                ;;
        esac
    done
}

start_game() {
    ready_game
    touch "${game_dir}/.metadata/score/start"
}

display_instructions() {
    exit_if_not_lock
    path=$(get_lock)
    cat "${path}/.metadata/instructions"
}

continue_game() {
    echo ""
    echo "$(localize "There is an error in your answer.")"
    echo ""
    echo "$(localize "If you want a hint, please refer below.")"
    echo "./practice_linux.sh hint"
    echo "$(localize "(However, it's not guaranteed that you'll always receive a hint.)")"
    exit
}

validate_validate() {
    local cur=$1

    if [ ! -e ".debug" ]; then
        if [ ! -e "${cur}/.metadata/validate_result_log" ]; then
            echo "$(localize "An irregularity with the game has been detected.")"
            exit 1
        fi

        if [ ! -e "${cur}/.metadata/validate_result_sh" ]; then
            echo "$(localize "An irregularity with the game has been detected.")"
            exit 1
        fi

        if [ ! -e "${cur}/.metadata/validate_result_file" ]; then
            echo "$(localize "An irregularity with the game has been detected.")"
            exit 1
        fi
    fi
}

end_game() {
    path=$(head -n 1 practice_linux/practice_linux.lock)
    validate_validate "${path}"
    echo "$(localize "Correct!")"
    echo "$(localize "Congratulations!")"
    echo ""
    
    touch "${path}/.metadata/score/end"
    if [ -e ".debug" ]; then
        touch "${path}/.metadata/.debug"
    fi
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
        echo "$(localize "There is no hint.")"
    fi
}

exit_if_not_games(){
    if [ ! -d "practice_linux/games" ]; then
        echo "$(localize "The game is not installed.")"
        echo "$(localize "Please start the game with ./practice_linux.sh start.")"
        exit
    fi
}

exit_if_not_lock(){
    if [ ! -e "practice_linux/practice_linux.lock" ]; then
        echo "$(localize "The game has not been started.")"
        echo "$(localize "Please start the game with ./practice_linux.sh start.")"
        exit
    fi
}

get_lock(){
    echo "$(head -n 1 practice_linux/practice_linux.lock)"
}

validate_result_log(){
    local cur=$1

    if [ ! -d "${cur}/answer" ]; then
        generate_hint "$(bind_str "$(localize "Please read the question carefully (Question {}).")" "1")"
        continue_game
    fi

    if [ ! -e "${cur}/answer/answer_log" ]; then
        generate_hint "$(bind_str "$(localize "Please read the question carefully (Question {}).")" "1")"
        continue_game
    fi
    answer_log_user="$(head -n 1 ${cur}/answer/answer_log)"
    answer_log_correct="$(head -n 1 ${cur}/.metadata/target_log_answer)"

    if [ "${answer_log_user}" != "${answer_log_correct}" ]; then
        generate_hint "$(localize "The date or time might be incorrect (Question 1).")"
        continue_game
    fi

    touch "${cur}/.metadata/validate_result_log"
}

validate_result_sh(){
    local cur=$1

    if [ ! -e "${cur}/bin/a/proc.sh" ]; then
        generate_hint "$(localize "Did you delete any existing files? (Question 2)")"
        continue_game
    fi
    if [ ! -e "${cur}/bin/b/proc.sh" ]; then
        generate_hint "$(localize "Did you delete any existing files? (Question 2)")"
        continue_game
    fi
    per_a=$(stat -c "%a" "${cur}/bin/a/proc.sh")
    if [ "$per_a" != "724" ]; then
        generate_hint "$(bind_str "$(localize "Is the permission of {} appropriate? Is the sh executable? Or did you change any unnecessary permissions? The default permission was {}. (Question 2)")" "${cur}/bin/a/proc.sh" "624")"
        continue_game
    fi
    per_b=$(stat -c "%a" "${cur}/bin/b/proc.sh")
    if [ "$per_b" != "742" ]; then
        generate_hint "$(bind_str "$(localize "Is the permission of {} appropriate? Is the sh executable? Or did you change any unnecessary permissions? The default permission was {}. (Question 2)")" "${cur}/bin/b/proc.sh" "642")"
        continue_game
    fi
    if [ ! -d "${cur}/bin/c" ]; then
        generate_hint "$(bind_str "$(localize "Please read the question carefully (Question {}).")" "2")"
        continue_game
    fi
    if [ ! -e "${cur}/bin/c/proc.sh" ]; then
        generate_hint "$(bind_str "$(localize "Please read the question carefully (Question {}).")" "2")"
        continue_game
    fi
    per_c=$(stat -c "%a" "${cur}/bin/c/proc.sh")
    if [ "$per_c" != "764" ]; then
        generate_hint "$(bind_str "$(localize "The permission of {} seems not appropriate. (Question {})")" "${cur}/bin/c/proc.sh" "2")"
        continue_game
    fi
    output_c=$(./${cur}/bin/c/proc.sh)
    if [ "$output_c" != "ccc" ]; then
        generate_hint "$(bind_str "$(localize "{} is operational, but the output is not as expected. (Question 2)")" "${cur}/bin/c/proc.sh")"
        continue_game
    fi

    touch "${cur}/.metadata/validate_result_sh"
}

validate_result_file(){
    local cur=$1

    # exists(dir)
    for file in "$cur/.metadata/rand/exists/dir"/*; do
        if [ -f "$file" ]; then
            exists_dir=$(head -n 1 ${file})
            if [ ! -d $exists_dir ]; then
                generate_hint "$(bind_str "$(localize "(Question 3) The expected directory does not seem to exist: {}")" "${exists_dir}")"
                continue_game
            fi
        fi
    done

    # not exists(dir)
    for file in "$cur/.metadata/rand/not_exists/dir"/*; do
        if [ -f "$file" ]; then
            exists_dir=$(head -n 1 ${file})
            if [ -d $exists_dir ]; then
                generate_hint "$(bind_str "$(localize "(Question 3) The unexpected directory seems to exist: {}")" "${exists_dir}")"
                continue_game
            fi
        fi
    done

    # exists(file)
    for file in "$cur/.metadata/rand/exists/file"/*; do
        if [ -f "$file" ]; then
            exists_file=$(head -n 1 ${file})
            if [ ! -e $exists_file ]; then
                generate_hint "$(bind_str "$(localize "(Question 3) The expected file does not seem to exist: {}")" "${exists_file}")"
                continue_game
            fi
        fi
    done

    # not exists(dir)
    for file in "$cur/.metadata/rand/not_exists/file"/*; do
        if [ -f "$file" ]; then
            exists_file=$(head -n 1 ${file})
            if [ -e $exists_file ]; then
                generate_hint "$(bind_str "$(localize "(Question 3) The unexpected file seems to exist: {}")" "${exists_file}")"
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
                    generate_hint "$(bind_str "$(localize "The permission of {} seems not appropriate. (Question {})")" "${GET[0]}" "3")"
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
                    generate_hint "$(bind_str "$(localize "The permission of {} seems not appropriate. (Question {})")" "${GET[0]}" "3")"
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
                    generate_hint "$(bind_str "$(localize "(Question 3) The timestamp of {} seems not appropriate.")" "${GET[0]}")"
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
                    generate_hint "$(bind_str "$(localize "(Question 3) The contents of {} seems not appropriate.")" "${GET[0]}")"
                    continue_game
                fi
            fi
        fi
    done

    touch "${cur}/.metadata/validate_result_file"
}

validate_result_all() {
    exit_if_not_lock
    cur=$(get_lock)
    
    if [ ! -e ".debug" ]; then
        # log
        validate_result_log "${cur}"

        # sh
        validate_result_sh "${cur}"

        # files and directories
        validate_result_file "${cur}"
    fi

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
                suffix="$(localize "  *in progress*")"
            else
                suffix=""
            fi
            message=""
            dir_name=$(basename "$dir")
            
            if [ ! -d "$dir/.metadata" ]; then
                message="$dir_name: $(localize "Illegal data(.metadata not exists)")${suffix}"
            elif [ ! -d "$dir/.metadata/score" ]; then
                message="$dir_name: $(localize "Illegal data(score not exists)")${suffix}"
            elif [ ! -f "$dir/.metadata/score/start" ]; then
                message="$dir_name: $(localize "Illegal data(start not exists)")${suffix}"
            elif [ ! -f "$dir/.metadata/score/end" ]; then
                message="$dir_name: $(localize "Incomplete")${suffix}"
            else
                message="$dir_name: $(localize "Completed")${suffix}"
            fi

            echo $message
        fi
    done

    if [ "$exists" = "" ]; then
        echo "$(localize "No games exists")"
    fi

    if [ -e ".debug" ]; then
        echo ""
        echo "$(localize "*** Running in debug mode ***")"
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
        echo "$(localize "No games have been completed")"
    else
        display_score_base $score_exists
    fi
}

check_score(){
    local opt=$1
    exit_if_not_games

    # If the argument does not consist of 0-9
    if [[ ! $opt =~ ^[0-9]+$ ]]; then
        return 1
    fi

    # If there is no practice_linux/games/number directory
    if [ ! -d "practice_linux/games/$opt" ]; then
        return 2
    fi

    return 0
}

delete_score(){
    local opt=$1
    while true; do
        echo "$(bind_str "$(localize "Game [{}] is going to be deleted.")" "${opt}")"
        read -p "$(localize "Are you sure you want to delete it?(Y/n)")" yn
        case $yn in
            [Yy]* )
                echo "$(bind_str "$(localize "{} has been deleted")" "${opt}")"
                rm -rf practice_linux/games/${opt}
                break;;
            [Nn]* )
                echo "$(localize "Cancelled deletion")"
                exit;;
            * )
                echo "$(localize "Enter Y or n.")";;
        esac
    done
}

checkout_score(){
    local opt=$1
    if [ -e "practice_linux/games/$opt/.metadata/score/end" ]; then
        echo "$(localize "The game has been completed and cannot be checked out")"
        exit
    fi
    
    if [ -e "practice_linux/practice_linux.lock" ]; then
        rm -f "practice_linux/practice_linux.lock"
    fi

    echo "practice_linux/games/$opt" > practice_linux/practice_linux.lock
    display_score_list
    echo ""
    echo "$(bind_str "$(localize "[{}] checkout has been completed.")" "${opt}")"
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
        echo "$(localize "No games have been completed")"
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
        echo "$(localize "No games have been completed")"
    fi
}

display_score_base(){
    local number=$1
    # This function must be called with various checks

    game_dir_temp="practice_linux/games/$number"

    if [ ! -e "${game_dir_temp}/.metadata/score/start" ]; then
        echo "$(localize "Data is invalid.")"
        echo "$(bind_str "$(localize "Manually delete {}, or")" "${game_dir_temp}")"
        echo "$(localize "Initialize the game data by executing ./practice_linux.sh format.")"
        exit
    fi

    start_formatted=$(date -r "${game_dir_temp}/.metadata/score/start" +"%Y/%m/%d %H:%M:%S")

    if [ ! -e "${game_dir_temp}/.metadata/score/end" ]; then
        echo "$(bind_str "$(localize "Game          : {}")" "${number}")"
        echo "$(bind_str "$(localize "Player        : {}")" "$(head -n 1 "${game_dir_temp}/.metadata/created_by")")"
        echo "$(bind_str "$(localize "Locale        : {}")" "$(localize "$(head -n 1 "${game_dir_temp}/.metadata/locale")")")"
        echo "$(bind_str "$(localize "Start datetime: {}")" "${start_formatted}")"
        echo "$(localize "This game has not been completed and therefore has no score.")"
        if [ -e ".debug" ]; then
            echo "$(localize "*** Running in debug mode ***")"
        fi
        echo "---------------------------"
        exit
    fi

    end_formatted=$(date -r "${game_dir_temp}/.metadata/score/end" +"%Y/%m/%d %H:%M:%S")

    echo "$(bind_str "$(localize "Game          : {}")" "${number}")"
    echo "$(bind_str "$(localize "Player        : {}")" "$(head -n 1 "${game_dir_temp}/.metadata/created_by")")"
    echo "$(bind_str "$(localize "Locale        : {}")" "$(localize "$(head -n 1 "${game_dir_temp}/.metadata/locale")")")"
    echo "$(bind_str "$(localize "Start datetime: {}")" "${start_formatted}")"
    echo "$(bind_str "$(localize "End   datetime: {}")" "${end_formatted}")"

    start_timestamp=$(date -r "${game_dir_temp}/.metadata/score/start" +%s)
    end_timestamp=$(date -r "${game_dir_temp}/.metadata/score/end" +%s)

    diff_seconds=$((end_timestamp - start_timestamp))

    hours=$((diff_seconds / 3600))
    minutes=$(((diff_seconds % 3600) / 60 ))
    seconds=$((diff_seconds % 60))

    echo "$(bind_str "$(localize "Required Time : {} hours {} minutes {} seconds")" "${hours}" "${minutes}" "${seconds}")"

    rank=$(get_rank "${hours}" "${minutes}" "${seconds}")
    echo "$(bind_str "$(localize "Rank          : {}")" "${rank}")"
    if [ -e "${game_dir_temp}/.metadata/.debug" ]; then
        echo "$(localize "*** Done with debug mode ***")"
    fi
    echo "---------------------------"
}

display_usage(){
    echo ""
    echo "Usage: ./practice_linux.sh {start|end|instructions|hint|score {list|all|<number>|highest|delete {<numbers>|}|}|list|locale {en|ja|}|checkout <numbers>|format|uninstall|version}"
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
    echo "list         : Alias for 'score list'"
    echo "locale       : Show current locale. Can be combined with:"
    echo "                - en         : Change locale to English."
    echo "                - ja         : Change locale to Japanese."
    echo "checkout <n> : Switch to uncompleted game with specific game number. You can get the list of numbers by 'score list'"
    echo "format       : Delete all scores and this app is going to be refreshed."
    echo "uninstall    : Delete all game datas."
    echo "version      : Display the version of practice_linux.sh"
    echo ""
    exit
}

display_app_version() {
    echo "${VERSION}"
}

case $1 in
    start)
        initialize_game
        echo ""
        echo "$(localize "Generating exercises... please wait a moment")"
        generate_directory_structure
        generate_logs
        generate_quiz_files
        generate_instructions
        echo "$(localize "Generation completed.")"
        start_game
        display_instructions
        ;;
    instructions)
        display_instructions
        ;;
    hint)
        display_hint
        ;;
    end)
        validate_result_all
        ;;
    format)
        initialize_app
        ;;
    uninstall)
        uninstall_app
        ;;
    score)
        case $2 in
            list)
                display_score_list
                ;;
            all)
                display_all_scores
                ;;
            highest)
                display_highest_score
                ;;
            delete)
                case $3 in
                    "")
                        initialize_app
                        ;;
                    *)
                        check_score $3
                        ret=$?
                        if [ $ret -ne 0 ]; then
                            # for debug
                            # echo "ret: $ret"
                            display_usage
                        fi
                        delete_score $3
                        ;;
                esac
                ;;
            "")
                display_score_latest
                ;;
            *)
                check_score $2
                ret=$?
                if [ $ret -ne 0 ]; then
                    # for debug
                    # echo "ret: $ret"
                    display_usage
                fi
                display_score_base $2
                ;;
        esac
        ;;
    list)
        display_score_list
        ;;
    locale)
        case $2 in
            "")
                display_locale
                ;;
            en)
                change_locale_en
                ;;
            ja)
                change_locale_ja
                ;;
            *)
                display_usage
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
    version)
        display_app_version
        ;;
    cm)
        # for debug option
        create_messages
        ;;
    *)
        display_usage
        ;;
esac
