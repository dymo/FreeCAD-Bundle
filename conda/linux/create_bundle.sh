# assume we have a working conda available
conda create \
    -p AppDir/usr freecad mamba libmamba \
    --copy \
    -c freecad/label/dev \
    -c conda-forge \
    -y

conda run -p AppDir/usr pip install https://github.com/looooo/freecad.appimage_updater/archive/master.zip

version_name=$(conda run -p AppDir/usr python get_freecad_version.py)

conda list -p AppDir/usr > AppDir/packages.txt
sed -i "1s/.*/\n\nLIST OF PACKAGES:/"  AppDir/packages.txt

#copy qt.conf
cp qt.conf AppDir/usr/bin/
cp qt.conf AppDir/usr/libexec/

# Add libnsl (Fedora 28 and up)
cp ../../libc6/lib/x86_64-linux-gnu/libnsl* AppDir/usr/lib/

# add documentation
if [ ${ADD_DOCS} ]
then
  mkdir -p AppDir/usr/share/doc/FreeCAD
  cp ../../doc/* AppDir/usr/share/doc/FreeCAD
fi


if [ "$DEPLOY_RELEASE" = "mamba" ]
            then
            export tag="mamba"
else
            export tag="latest"
fi


# create the appimage
chmod a+x ./AppDir/AppRun
ARCH=x86_64 ../../appimagetool-x86_64.AppImage \
  -u "gh-releases-zsync|FreeCAD|FreeCAD-Appimage|$tag|FreeCAD*glibc2.12-x86_64.AppImage.zsync" \
  AppDir  ${version_name}.AppImage

# create hash
shasum -a 256 ${version_name}.AppImage > ${version_name}.AppImage-SHA256.txt
