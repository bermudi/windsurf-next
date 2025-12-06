Download instructions for Linux
===============================

Download instructions for deb-based Linux distributions (e.g. Ubuntu 20.04+, Debian 10+)

1\. Add the repository to sources.list.d

```
sudo apt-get install wget gpg
wget -qO- "https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/windsurf.gpg" | gpg --dearmor > windsurf-next.gpg
sudo install -D -o root -g root -m 644 windsurf-next.gpg /etc/apt/keyrings/windsurf-next.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/windsurf-next.gpg] https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/apt next main" | sudo tee /etc/apt/sources.list.d/windsurf-next.list > /dev/null
rm -f windsurf-next.gpg
```

2\. Update

```
sudo apt install apt-transport-https
sudo apt update
```

3\. Install

```
sudo apt install windsurf-next
```

Download instructions for rpm-based Linux distributions (e.g. Fedora 36+, Centos 8+)

1\. Import the signing key

```
sudo rpm --import https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/yum/RPM-GPG-KEY-windsurf
```

2\. Add the repo to /etc/yum.repos.d

```
echo -e "[windsurf-next]
name=Windsurf Next Repository
baseurl=https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/yum/repo/
enabled=1
autorefresh=1
gpgcheck=1
gpgkey=https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/yum/RPM-GPG-KEY-windsurf" | sudo tee /etc/yum.repos.d/windsurf-next.repo > /dev/null

```

3\. Update

```
sudo dnf check-update
```

4\. Install

```
sudo dnf install -y windsurf-next
```

You can also use the [repo file](https://windsurf-stable.codeiumdata.com/mQfcApCOdSLoWOSI/yum/windsurf-next.repo) if you prefer.

Using another distribution? You can download the source tarball

.