package {
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.NetConnection;
    import flash.events.NetStatusEvent;
    import flash.net.NetStream;
    import flash.media.Video;
    import flash.utils.setTimeout;

    public class Main extends Sprite {
        public static const SERVER: String = 'http://axgmbp:8080/';
        private var connection: NetConnection = new NetConnection();
        private var stream: NetStream;
        private var videoURL: String;
        private var videoPos: int;
        private var videoLen: int;
        private var sync: Boolean = true;
        private var prev: Number = -1;
        private var timeStamp: Number;

        public function Main() {
            connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            addEventListener(Event.ADDED_TO_STAGE, initialize);
        }

        private function initialize(event: Event): void {
            var loader: URLLoader = new URLLoader();
            loader.addEventListener(Event.COMPLETE, completeHandler);
            var request: URLRequest = new URLRequest(SERVER + 'status');
            loader.load(request);
        }

        private function completeHandler(event: Event): void {
            timeStamp = new Date().time;
            var loader:URLLoader = URLLoader(event.target);
            var a: Array = loader.data.split('\n');
            videoURL = SERVER + a[0];
            videoPos = parseInt(a[1]);
            videoLen = parseInt(a[2]);
            connection.connect(null);
        }

        private function netStatusHandler(event: NetStatusEvent): void {
            trace(event.info.code);
            switch (event.info.code) {
                case 'NetConnection.Connect.Success':
                    connectStream();
                    break;
                case 'NetStream.Play.StreamNotFound':
                    trace('Unable to locate video: ' + videoURL);
                    break;
                case 'NetStream.Buffer.Empty':
                    stream.seek(0);
                    stream.resume();
                    break;
                case 'NetStream.Buffer.Full':
                    if (sync) {
                        var p: Number = videoPos / 1000;
                        if (p >= stream.time - 3 && prev != stream.time) {
                            prev = stream.time;
                            trace('Current:', stream.time, 'Target:', p);
                            setTimeout(function(): void {
                                var ntime: Number = new Date().time;
                                var d: Number = ntime - timeStamp;
                                timeStamp = ntime;
                                trace('Correction:', d);
                                videoPos += d;
                                if (videoPos > videoLen) videoPos = videoLen - videoPos;
                                stream.seek(p + d / 1000);
                            }, 50);
                        } else {
                            sync = false;
                        }
                    }
                    break;
            }
        }

        private function connectStream(): void {
            trace('connectStream', videoURL);
            if (stream) stream.dispose();
            stream = new NetStream(connection)
            stream.inBufferSeek = true;
            stream.client = {};
            stream.client.onMetaData = streamMetaHandler;
            stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            var video: Video = new Video();
            video.attachNetStream(stream);
            stream.play(videoURL);
            addChild(video)
        }

        private function streamMetaHandler(info: Object): void {
            // trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height);
        }

    }
}