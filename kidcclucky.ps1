# 执行脚本前先以管理员权限设置脚本执行策略
# set-executionpolicy remotesigned

$ip = (ipconfig|select-string "IPv4"|out-string).Split(" : ")[-1].Trim()

$timestamp = (([DateTime]::Today.ToUniversalTime().Ticks - 621355968000000000) / 10000000).tostring().Substring(0, 10)

$data = -Join($ip, $timestamp, "kidcc")

$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider

$coding = New-Object -TypeName System.Text.UTF8Encoding

$hash = [System.BitConverter]::ToString($md5.ComputeHash($coding.GetBytes($data))).replace('-','').ToLower()
#生成规则为md5/32位：小，取其中0到8位并加上英文符@#ylimly固定字符串。
#其中@#ylimly是为了满足windows密码复杂性要求策略。
$password = -Join($hash.substring(0, 8),"@#ylimly")

$ip
$timestamp
$password

# 修改用户密码
net user ceshi1 $password