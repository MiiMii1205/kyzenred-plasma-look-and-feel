 # Kyzenred Hacking

So you want to extend the theme, yes? First up, let's talk about what you'll need!

first, you need to know that, like many KDE splash screens, Kyzenred uses a [QML](https://doc.qt.io/qt-5/qmlreference.html) file to render the splash screen.

[QML](https://doc.qt.io/qt-5/qmlreference.html) is a special markup language used by Qt to build a node graph (or a whole splash screen if you want)

[QML](https://doc.qt.io/qt-5/qmlreference.html) also support JavaScript, which is used by Kyzenred to fetch the current color scheme and to dynamically recolor SVGs.

Second, you need to know that Kvantum is a pure SVG engine. This means that if you want to change things you'll need to know how SVGs works, along with good HTML and CSS knowledge.

Thankfully, there's [w3school](https://www.w3schools.com/graphics/svg_intro.asp). With their little SVG reference you'll be ready in no time to edit the theme!

## Recoloring
Kyzenred is dynamically colored theme. This means that its components are dynamically recolored based on the current color scheme.

Because [QML](https://doc.qt.io/qt-5/qmlreference.html) by itself barely has support for full system access, we need to use a finicky hack to make it work.

This is why the splash screen's location is critical. We are essentially using a buch of relative path to fetch the `~/.config/kdeglobals` file and read the current color scheme form it.

To achieve this, we use a simple [XMLHttpRequest](https://www.w3schools.com/js/js_ajax_http.asp) to fetch the `~/.config/kdeglobals`.
We then generate a stylesheet from it and also change any color we want from the splash screen.

But then, we're faced with another problem: [QML](https://doc.qt.io/qt-5/qmlreference.html) only supports SVG files trough their [`Image` QML item](https://doc.qt.io/qt-5/qml-qtquick-image.html). This effectively means that as soon as [QML](https://doc.qt.io/qt-5/qmlreference.html) receives the SVG file it immediately renders it into a raster image. This is bad: we need to load an SVG file and change the whole color scheme *BEFORE* rendering.

The solution? using a `data:` URL.

With a special encoder, we can set the image source of an [`Image` QML item](https://doc.qt.io/qt-5/qml-qtquick-image.html) to an actual SVG rather than to an SVG file path. We can then replace anything we want in it and parse it into pure data which is then sent to [QML](https://doc.qt.io/qt-5/qmlreference.html) who immediately renders it.

So, to put it simply, we:

1. Fetch the current color scheme;
2. Assign the fetched colors to some [QML](https://doc.qt.io/qt-5/qmlreference.html) items;
2. Generate the special `<style>` tag;
3. Fetch the needed SVG file;
4. Insert the generated `<style>` tag;
5. Parse the whole SVG file into a `data:` URL;
6. Give the URL to [QML](https://doc.qt.io/qt-5/qmlreference.html).

After this is done, the whole splash screen is now fully recolored and ready to play!
