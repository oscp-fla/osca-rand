#!/bin/bash
echo "choose op :
1  --backup -s -d -r
2  --report -o
3  --logs -f
4  --send -f -t -p -e
5  --win -t -p "
read -p "choose operation: " op
if [ "$op" == "1" ]; then
    read -p "enter source: " s
    read -p "enter destination: " d
    read -p "enter retention days: " r
    if [ -d "$s" ] && [[ "$r" =~ ^[0-9]+$ ]] && [ -n "$d" ]; then
        if mkdir -p "$d"; then
            backup="backup_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"

            if tar -czf "$d/$backup" -C "$(dirname "$s")" "$(basename "$s")"; then
                echo "Backup completed"
                du -h "$d/$backup"
                echo "Retention days: $r"
                echo "Automatic deletion of old backups is not implemented yet."
            else
                echo "Backup failed"
            fi
        else
            echo "Cannot create destination folder"
        fi
    else
        echo "Invalid source, destination, or retention days"
    fi

elif [ "$op" == "2" ]; then

    read -p "Enter report folder: " o

    if [ -n "$o" ] && mkdir -p "$o"; then
        report="$o/report_$(date +%Y-%m-%d_%H-%M-%S).txt"

        {
            echo "SystemCare Report"
            echo "Date: $(date)"
            echo "User: $(whoami)"
            echo ""
            echo "Disk Usage:"
            df -h
            echo ""
            echo "Memory Usage:"
            free -h
            echo ""
            echo "Top Processes:"
            ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6
        } | tee "$report"

        echo "Report saved to $report"
    else
        echo "Cannot create report folder"
    fi

elif [ "$op" == "3" ]; then

    read -p "Enter log file path: " f

    if [ -f "$f" ]; then
        echo "Failed login attempts:"
        grep -iE "failed password|authentication failure|failed login" "$f" || echo "No matching failed login entries found"

        echo "Most frequent IP addresses:"
        grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$f" |
            sort | uniq -c | sort -nr | head -n 10
    else
        echo "Log file does not exist"
    fi

elif [ "$op" == "4" ]; then

    read -p "Enter file path to send: " f
    read -p "Enter destination IP address: " t
    read -p "Enter destination port: " p
    read -p "Enter certificate path: " e

    if [ -f "$f" ] && [ -f "$e" ]; then
        echo "File and certificate found."
        echo "TLS transfer is not implemented yet."
        echo "Destination: $t"
        echo "Port: $p"
    else
        echo "File or certificate does not exist"
    fi

elif [ "$op" == "5" ]; then

    read -p "Enter Windows IP address: " t
    read -p "Enter Windows port: " p

    if command -v powershell.exe >/dev/null 2>&1; then
        powershell.exe -Command "Get-ComputerInfo | Select-Object CsName, WindowsProductName"
    else
        echo "Windows PowerShell is not available on this system."
        echo "Remote Windows monitoring is not implemented yet."
        echo "Target: $t"
        echo "Port: $p"
    fi

else
    echo "Choose a valid number"
fi

