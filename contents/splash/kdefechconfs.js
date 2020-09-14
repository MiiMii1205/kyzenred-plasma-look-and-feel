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

function fetchHostName() {
    getFile("/etc/hostname", (data)=> {
        kyzen_text.text=data.replace('\n', "");
    })
}