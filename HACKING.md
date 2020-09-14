 # Kyzenred Hacking

So you want to extend the theme, yes? First up, let's talk about what you'll need!

first, you need to know that, like many KDE splash screens, Kyzenred uses a [QML](https://doc.qt.io/qt-5/qmlreference.html) file to render the splash screen.

[QML](https://doc.qt.io/qt-5/qmlreference.html) is a special markup language used by Qt to build a node graph (or a whole splash screen if you want)

[QML](https://doc.qt.io/qt-5/qmlreference.html) also support JavaScript, which is used by Kyzenred to fetch some of your systems information, namely the current hostname.

Second, you need to know that QML uses something similar to SVG's paths to draw complex shapes with it's special [Shape](https://doc.qt.io/qt-5/qml-qtquick-shapes-shape.html) item. [For more details, check this out](https://doc.qt.io/qt-5/qml-qtquick-pathsvg.html)

Thankfully, there's [w3school](https://www.w3schools.com/graphics/svg_intro.asp). With their little SVG reference you'll be ready in no time to edit the theme!

## Recoloring
Kyzenred is a dynamically colored theme. This means that its components are dynamically recolored based on the current color scheme.

Because [QML](https://doc.qt.io/qt-5/qmlreference.html) by itself barely has support for full system access, we need to import KDE's own library too.

[KDE's QtQuick's library](https://api.kde.org/frameworks/plasma-framework/html/index.html) gives us a whole lot of information on the current KDE color scheme and theme. From there, it's easy to assign different colors to any component we like. 

Check out [KDE's QtQuick API](https://api.kde.org/frameworks/plasma-framework/html/index.html) for more details.
