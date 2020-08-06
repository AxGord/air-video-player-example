package {
    import flash.display.Sprite;
    import flash.events.Event;

    public class Main extends Sprite
    {
        public function Main(){
            addEventListener(Event.ADDED_TO_STAGE, initialize);
        }

        private function initialize(event:Event):void{
            trace('Init');
        }
    }
}