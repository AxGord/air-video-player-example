import pony.time.DTimer;
import pony.net.http.IHttpConnection;
import pony.net.http.platform.nodejs.HttpServer;
import pony.Config;

class Main {

	private final server: HttpServer = new HttpServer(Config.server_port);
	private final timer: DTimer = DTimer.createTimer(Config.video_length, -1);

	public function new() {
		server.request = requestHandler;
		timer.start();
	}

	private function requestHandler(connection: IHttpConnection): Void {
		switch connection.url {
			case '': connection.sendHtml("Video server");
			case 'status': connection.sendText(Config.video_file + '\n' + timer.currentTime.totalMs);
			case Config.video_file: connection.sendFile(Config.video_file);
			case _: connection.notfound();
		}
	}

	private static function main(): Void new Main();

}