# ִ�нű�ǰ���Թ���ԱȨ�����ýű�ִ�в���
# set-executionpolicy remotesigned

$ip = (ipconfig|select-string "IPv4"|out-string).Split(" : ")[-1].Trim()

$timestamp = (([DateTime]::Today.ToUniversalTime().Ticks - 621355968000000000) / 10000000).tostring().Substring(0, 10)

$data = -Join($ip, $timestamp, "kidcc")

$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider

$coding = New-Object -TypeName System.Text.UTF8Encoding

$hash = [System.BitConverter]::ToString($md5.ComputeHash($coding.GetBytes($data))).replace('-','').ToLower()
#���ɹ���Ϊmd5/32λ��С��ȡ����0��8λ������Ӣ�ķ�@#ylimly�̶��ַ�����
#����@#ylimly��Ϊ������windows���븴����Ҫ����ԡ�
$password = -Join($hash.substring(0, 8),"@#ylimly")

$ip
$timestamp
$password

# �޸��û�����
net user ceshi1 $password