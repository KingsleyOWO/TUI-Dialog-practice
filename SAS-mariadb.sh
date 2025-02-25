#!/bin/bash

# 簡化版 MariaDB 安裝管理腳本
# 功能：安裝、卸載及查看 MariaDB 服務狀態

# 檢查 root 權限
[ "$(id -u)" -ne 0 ] && { echo "請以 root 權限運行"; exit 1; }

# 安裝 dialog (如需要)
command -v dialog &>/dev/null || { apt-get update && apt-get install -y dialog || yum install -y dialog; }

# 安裝 MariaDB
install_mariadb() {
    dialog --title "安裝 MariaDB" --yesno "確定要安裝 MariaDB 嗎？" 7 50
    [ $? -ne 0 ] && return
    
    {
        echo "10"; echo "# 更新軟件包..."; apt-get update -y || yum update -y
        echo "40"; echo "# 安裝 MariaDB..."; apt-get install -y mariadb-server || yum install -y mariadb-server
        echo "70"; echo "# 啟動 MariaDB..."; systemctl start mariadb; systemctl enable mariadb
        echo "100"
    } | dialog --title "安裝進度" --gauge "正在安裝 MariaDB..." 10 60 0
    
    systemctl is-active --quiet mariadb && \
    dialog --title "成功" --msgbox "MariaDB 已安裝！\n建議運行: mysql_secure_installation" 8 50 || \
    dialog --title "失敗" --msgbox "安裝失敗，請檢查系統日誌。" 7 50
}

# 卸載 MariaDB
uninstall_mariadb() {
    dialog --title "卸載 MariaDB" --yesno "警告：將刪除所有數據庫！確定繼續嗎？" 7 50
    [ $? -ne 0 ] && return
    
    {
        echo "25"; echo "# 停止服務..."; systemctl stop mariadb; systemctl disable mariadb
        echo "50"; echo "# 卸載 MariaDB..."; apt-get remove --purge -y mariadb-server mariadb-client || yum remove -y mariadb-server mariadb
        echo "75"; echo "# 清理數據..."; rm -rf /var/lib/mysql /etc/mysql
        echo "100"; echo "# 完成清理..."; apt-get autoremove -y || yum autoremove -y
    } | dialog --title "卸載進度" --gauge "正在卸載 MariaDB..." 10 60 0
    
    dialog --title "完成" --msgbox "MariaDB 已卸載。" 5 40
}

# 查看狀態
check_status() {
    if ! command -v mysql &>/dev/null; then
        dialog --title "狀態" --msgbox "MariaDB 尚未安裝。" 5 40
        return
    fi
    
    version=$(mysql --version 2>&1)
    service_status=$(systemctl is-active --quiet mariadb && echo "運行中" || echo "已停止")
    startup_status=$(systemctl is-enabled --quiet mariadb && echo "已啟用" || echo "已禁用")
    
    dialog --title "MariaDB 狀態" --msgbox "版本：$version\n\n狀態：$service_status\n自啟：$startup_status" 10 60
}

# 啟動/停止服務
toggle_service() {
    if ! command -v mysql &>/dev/null; then
        dialog --title "錯誤" --msgbox "MariaDB 尚未安裝。" 5 40
        return
    fi
    
    if systemctl is-active --quiet mariadb; then
        # 服務正在運行，詢問是否停止
        dialog --title "停止服務" --yesno "MariaDB 正在運行，要停止嗎？" 6 50
        [ $? -eq 0 ] && systemctl stop mariadb && \
        dialog --title "成功" --msgbox "MariaDB 服務已停止。" 5 40
    else
        # 服務已停止，詢問是否啟動
        dialog --title "啟動服務" --yesno "MariaDB 已停止，要啟動嗎？" 6 50
        [ $? -eq 0 ] && systemctl start mariadb && \
        dialog --title "成功" --msgbox "MariaDB 服務已啟動。" 5 40 || \
        dialog --title "失敗" --msgbox "啟動失敗，請檢查系統日誌。" 6 45
    fi
}

# 主菜單
while true; do
    choice=$(dialog --clear --title "MariaDB 管理工具" \
                   --menu "請選擇:" 12 45 5 \
                   "1" "安裝 MariaDB" \
                   "2" "卸載 MariaDB" \
                   "3" "查看狀態" \
                   "4" "啟動/停止服務" \
                   "5" "退出" \
                   3>&1 1>&2 2>&3)
    
    clear
    case $choice in
        1) install_mariadb ;;
        2) uninstall_mariadb ;;
        3) check_status ;;
        4) toggle_service ;;
        5|*) exit 0 ;;
    esac
done