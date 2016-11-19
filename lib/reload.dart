const livereload = '''<script>
var filename = '{{filename}}';

function connect() {
  return new Promise(function(resolve, reject) {
    var ws = new WebSocket('ws://' + window.location.host);

    ws.onmessage = function(e) {
      var packet = JSON.parse(e.data);
      console.info(packet, filename);

      if (packet.filename === filename) {
        console.log('Changes detected - now reloading!');
        window.location.reload();
      }
    };

    ws.onopen = function() {
      console.log('Now connected to markymark server.');
      return resolve(ws);
    };

    ws.onerror = function(err) {
      return false;
    };

    ws.onclose = function() {
      console.error('Connection to server lost. Waiting for connection to be restored...');
      connect();
    };
  });
}

connect();
</script>''';
