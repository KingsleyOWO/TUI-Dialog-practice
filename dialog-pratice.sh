
account=$(dialog --stdout --title "請輸入帳號" --inputbox "你的帳號" 10 50)
password=$(dialog --stdout --title "請輸入密碼" --inputbox "你的密碼" 10 50)
reg_date=$(dialog --stdout --calendar "選擇註冊日期" 0 0)
local_ip=$(hostname -I | awk '{print $1}')
local_ping=$(ping -c 2 "$local_ip")
local_speed=$(echo "$local_ping" | tail -1 | awk -F '/' '{print $5}')
google_ping=$(ping -c 2 8.8.8.8)
dialog --title "Ping 測試結果" --msgbox "本機 IP ($local_ip) 的 ping 結果:\n$local_ping\n\n8.8.8.8 的 ping 結果:\n$google_ping" 20 80
dialog --title "性別猜測" --yesno "你帶不帶把?" 10 50; a=$?
dialog --title "性別猜測" --yesno "你有喉結嗎?" 10 50; b=$?
[[ $a -eq $b ]] && gender=$([[ $a -eq 0 ]] && echo "男生" || echo "女生") || gender="性別判斷失敗"
{
  echo "10"
  sleep 1
  echo "30"
  sleep 1
  echo "60"
  sleep 1
  echo "90"
  sleep 1
  echo "100"
} | dialog --title "數據處理分析中( ◕‿‿◕ )" --gauge "目前進度" 10 50 0

dialog --title "所有得到的資訊" --msgbox "
帳號: $account
密碼: $password
註冊日期: $reg_date
大膽猜測您的性別: $gender
本地網路速度 (平均 ping): ${local_speed} ms" 15 60
