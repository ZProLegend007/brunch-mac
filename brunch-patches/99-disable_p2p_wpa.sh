ret=0

if [ ! -f /roota/usr/lib64/shill/shims/wpa_supplicant.conf ]; then
    echo "Error: File /roota/usr/lib64/shill/shims/wpa_supplicant.conf not found."
    exit 1
fi

echo "p2p_disabled=1" >> /roota/usr/lib64/shill/shims/wpa_supplicant.conf
if [ ! "$?" -eq 0 ]; then
    echo "Error: Failed to add the line to /roota/usr/lib64/shill/shims/wpa_supplicant.conf."
    ret=$((ret + (2 ** 0)))
fi

exit $ret
