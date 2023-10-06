#!/bin/bash
#--exclude=discord.desktop

cd ~/Downloads/;
wget https://dl.discordapp.net/apps/linux/$1/discord-$1.tar.gz;
tar -xvf discord-$1.tar.gz;
cd Discord;
sudo cp -r chrome_100_percent.pak chrome-sandbox discord.png libffmpeg.so libvulkan.so.1 resources v8_context_snapshot.bin chrome_200_percent.pak Discord icudtl.dat libGLESv2.so locales resources.pak vk_swiftshader_icd.json chrome_crashpad_handler libEGL.so postinst.sh snapshot_blob.bin /opt/discord;
cd ..;
echo cleanup;
rm discord-$1.tar.gz;
rm -r Discord;
cd -
