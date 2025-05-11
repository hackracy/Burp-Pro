#!/bin/bash

OR='\e[38;5;202m'
GR='\e[32m'
NL='\e[0m'
WH='\e[97m'
BL='\e[34m'

echo -e "${GR}
 ____ ___ _     ____  _   _ _   _ ____  ____   _    
|  _ \_ _| |   / ___|| | | | | | |  _ \|  _ \ / \   
| | | | || |   \___ \| |_| | | | | |_) | |_) / _ \  
| |_| | || |___ ___) |  _  | |_| |  __/|  __/ ___ \ 
|____/___|_____|____/|_| |_|\___/|_|   |_| /_/   \_\\
${NL}"

echo "  This script is made by Dilshuppa"
echo

# === Check for root ===
if [[ $EUID -ne 0 ]]; then
    echo "❌ Please run this script as root"
    exit 1
fi

# === Setup Java JDK 19 if not found ===
if ! command -v javac >/dev/null 2>&1; then
    echo "☕ Installing Java JDK 19..."
    mkdir -p /usr/local/java/jdk19
    curl -L https://download.oracle.com/java/19/archive/jdk-19_linux-x64_bin.tar.gz -o jdk19.tar.gz
    tar -xf jdk19.tar.gz -C /usr/local/java/jdk19 --strip-components=1
    rm jdk19.tar.gz

    sudo update-alternatives --install /usr/bin/java java /usr/local/java/jdk19/bin/java 1
    sudo update-alternatives --install /usr/bin/javac javac /usr/local/java/jdk19/bin/javac 1
    echo "✅ Java JDK 19 installed"
fi

# === Install Burp Suite Pro ===
echo "📦 Setting up Burp Suite Pro..."
mkdir -p /usr/share/burpsuite
cp loader.jar /usr/share/burpsuite/
cp burp_suite.ico /usr/share/burpsuite/
cd /usr/share/burpsuite || exit

# Remove any previous version
rm -f burpsuite_pro_v*.jar

# Download latest Burp Pro jar
version=$(curl -s https://portswigger.net/burp/releases | grep -Po '(?<=/burp/releases/professional-community-)[0-9]+\-[0-9]+\-[0-9]+' | head -n1)
link="https://portswigger-cdn.net/burp/releases/download?product=pro&version=&type=jar"
wget "$link" -O burpsuite_pro_v$version.jar --quiet --show-progress

# Create launcher script
cat > /usr/share/burpsuite/burpsuite <<EOF
#!/bin/bash
cd /usr/share/burpsuite
java -Duser.home=/root \\
  --add-opens=java.desktop/javax.swing=ALL-UNNAMED \\
  --add-opens=java.base/java.lang=ALL-UNNAMED \\
  --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED \\
  --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED \\
  --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED \\
  -javaagent:loader.jar \\
  -noverify -jar burpsuite_pro_v$version.jar &
EOF

chmod +x /usr/share/burpsuite/burpsuite
ln -sf /usr/share/burpsuite/burpsuite /usr/local/bin/burpsuite

# Launch Keygen in background
echo "🔑 Starting Key Generator..."
(java -jar loader.jar &) &

# Final message
echo "✅ Burp Suite Pro installed successfully!"
echo "💡 Use 'burpsuite' to launch it anytime (with Pro settings)."
