
function ini_dotSplit(str) {
    return str.replace(/\1/g, '\u0002LITERAL\\1LITERAL\u0002')
        .replace(/\\\./g, '\u0001')
        .split(/\./).map(function (part) {
            return part.replace(/\1/g, '\\.')
                .replace(/\2LITERAL\\1LITERAL\2/g, '\u0001')
        })
}



function ini_decode(str) {
    var out = {}
    var p = out
    var section = null
    //          section     |key      = value
    var re = /^\[([^\]]*)\]$|^([^=]+)(=(.*))?$/i
    var lines = str.split(/[\r\n]+/g)

    lines.forEach(function (line, _, __) {
        if (!line || line.match(/^\s*[;#]/)) return
        var match = line.match(re)
        if (!match) return
        if (match[1] !== undefined) {
            section = ini_unsafe(match[1])
            p = out[section] = out[section] || {}
            return
        }
        var key = ini_unsafe(match[2])
        var value = match[3] ? ini_unsafe(match[4]) : true
        switch (value) {
            case 'true':
            case 'false':
            case 'null': value = JSON.parse(value)
        }

        // Convert keys with '[]' suffix to an array
        if (key.length > 2 && key.slice(-2) === '[]') {
            key = key.substring(0, key.length - 2)
            if (!p[key]) {
                p[key] = []
            } else if (!Array.isArray(p[key])) {
                p[key] = [p[key]]
            }
        }

        // safeguard against resetting a previously defined
        // array by accidentally forgetting the brackets
        if (Array.isArray(p[key])) {
            p[key].push(value)
        } else {
            p[key] = value
        }
    })

    // {a:{y:1},"a.b":{x:2}} --> {a:{y:1,b:{x:2}}}
    // use a filter to return the keys that have to be deleted.
    Object.keys(out).filter(function (k, _, __) {
        if (!out[k] ||
            typeof out[k] !== 'object' ||
            Array.isArray(out[k])) {
            return false
        }
        // see if the parent section is also an object.
        // if so, add it to that, and mark this one for deletion
        var parts = ini_dotSplit(k)
        var p = out
        var l = parts.pop()
        var nl = l.replace(/\\\./g, '.')
        parts.forEach(function (part, _, __) {
            if (!p[part] || typeof p[part] !== 'object') p[part] = {}
            p = p[part]
        })
        if (p === out && nl === l) {
            return false
        }
        p[nl] = out[k]
        return true
    }).forEach(function (del, _, __) {
        delete out[del]
    })

    return out
}

function ini_isQuoted(val) {
    return (val.charAt(0) === '"' && val.slice(-1) === '"') ||
        (val.charAt(0) === "'" && val.slice(-1) === "'")
}

function ini_unsafe(val, doUnesc) {
    val = (val || '').trim()
    if (ini_isQuoted(val)) {
        // remove the single quotes before calling JSON.parse
        if (val.charAt(0) === "'") {
            val = val.substr(1, val.length - 2)
        }
        try { val = JSON.parse(val) } catch (_) { }
    } else {
        // walk the val to find the first not-escaped ; character
        var esc = false
        var unesc = ''
        for (var i = 0, l = val.length; i < l; i++) {
            var c = val.charAt(i)
            if (esc) {
                if ('\\;#'.indexOf(c) !== -1) {
                    unesc += c
                } else {
                    unesc += '\\' + c
                }
                esc = false
            } else if (';#'.indexOf(c) !== -1) {
                break
            } else if (c === '\\') {
                esc = true
            } else {
                unesc += c
            }
        }
        if (esc) {
            unesc += '\\'
        }
        return unesc.trim()
    }
    return val
}

function componentToHex(c) {
    var hex = parseInt(c).toString(16);
    return hex.length == 1 ? "0" + hex : hex;
}

function rgb2Hex(r, g, b) {
    return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b);
}

function getKDEColor(group, color, data) {
    return rgb2Hex(...data[`Colors:${group}`][color].split(','));
}

function encodeSVG(s) {

    s = s.replace(/"/g, `'`);
    s = s.replace(/>\s{1,}</g, `><`);
    s = s.replace(/\s{2,}/g, ` `);

    return s.replace(/[\r\n%#()<>?[\\\]^`{|}]/g, encodeURIComponent);
}


function getFile(path, cb) {
    var doc = new XMLHttpRequest();

    doc.onreadystatechange = function () {
        if (doc.readyState == XMLHttpRequest.DONE) {
            cb(doc.responseText);
        }
    }
    doc.open("GET", path);
    doc.send();

}

function makeKDERequest() {

    // I hate this but it'll have to do. Let's pray there are no special KDE stuffs.
    getFile("../../../../../../../.config/kdeglobals", (data) => {
        var ini = ini_decode(data);
        kyzen_text.color = getKDEColor("Button", "DecorationHover", ini);
        kyzen_revealer.gradient.stops[1].color = root.color = getKDEColor("Window", "BackgroundNormal", ini);

        var stylesheet = `
        .ColorScheme-Text{color:${getKDEColor("Window", "ForegroundNormal", ini)};}
        .ColorScheme-Background{color:${getKDEColor("Window", "BackgroundNormal", ini)};}
        .ColorScheme-Highlight{color:${getKDEColor("Selection", "BackgroundNormal", ini)};}
        .ColorScheme-ViewText{color:${getKDEColor("View", "ForegroundNormal", ini)};}
        .ColorScheme-ViewBackground{color:${getKDEColor("View", "BackgroundNormal", ini)};}
        .ColorScheme-ViewHover{color:${getKDEColor("View", "DecorationHover", ini)};}
        .ColorScheme-ViewFocus{color:${getKDEColor("View", "DecorationFocus", ini)};}
        .ColorScheme-ButtonText{color:${getKDEColor("Button", "ForegroundNormal", ini)};}
        .ColorScheme-ButtonBackground{color:${getKDEColor("Button", "BackgroundNormal", ini)};}
        .ColorScheme-ButtonHover{color:${getKDEColor("Button", "DecorationHover", ini)};}
        .ColorScheme-ButtonFocus{color:${getKDEColor("Button", "DecorationFocus", ini)};}
        `
        getFile("./images/kyzen-bracket.svg", (svg) => {
            bottom_left_bracket.source = top_right_bracket.source = `data:image/svg+xml,${encodeSVG(svg.replace(/(<style(\s|\S)*?id="current-color-scheme"(\s|\S)*?<\/style>)/g, `<style id="current-color-scheme">${stylesheet}</style>`))}`
        })
    })
}
