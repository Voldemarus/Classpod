<?

$p = $_GET["type"];
if ($p != "mymusic") {
    echo "Not support parameters... Better Call Saul...";
    exit(13);
}

// Исходники: https://sourceforge.net/projects/getid3/

//in brouser type:  https://classpod.ildd.ru/

//set variables
function mb_unserialize($string) {
    $string = preg_replace_callback('/!s:(\d+):"(.*?)";!se/', function($matches) { return 's:'.strlen($matches[1]).':"'.$matches[1].'";'; }, $string);
    return unserialize($string);
}

$settings = array(
    'name' => 'Name radiostation', // Название вашей радиостанции.
    'genre' => 'Electronic', // Не обязательно должен быть в формате MP3, может быть любым.
    'url' => $_SERVER['HTTP_HOST'], // URL станции, автоматически генерируется PHP.
    'bitrate' => 128, // Битрейт передачи в кбит / с. Все аудио, но должны быть перекодированы до этого битрейта.
    'music_directory' => "music/", // Папка, в которой находится звук.
    'database_file' => "music.db", // Имя файла кэша метаданных аудио.
    'buffer_size' => 16384, // Размер буфера ледяных данных, не очень важно.
                            // Чем больше буфер, тем меньше обновлений текущего названия песни.
    'max_listen_time' => 14400, // Максимальное время прослушивания пользователя в секундах. Установите 4 часа.
    'randomize_seed' => 0, // 31337,     // Начальное число псевдослучайного списка воспроизведения.
                                // Должен быть установлен на contant, иначе клиенты не будут синхронизироваться. );
                                // The seed of the pseudo random playlist.
                                // Must be set to a contant otherwise the clients won't be in sync. );
);


set_time_limit(0);
require_once("getid3/getid3.php");
$getID3 = new getID3();

//load playlist

$playfiles = json_decode(file_get_contents($settings["database_file"]), true);

$total_playtime = 0;

//set playlist
$start_time = microtime(true);
srand($settings["randomize_seed"]);
// shuffle($playfiles);
//sum playtime
foreach($playfiles as $playfile) {
    $total_playtime += $playfile["playtime"];
}

//calculate the current song
$play_pos = $start_time % $total_playtime;


foreach($playfiles as $i=>$playfile) {
    $play_sum += $playfile["playtime"];
    if($play_sum > $play_pos) {
        break;
    }
}
$track_pos = ($playfiles[$i]["playtime"] - $play_sum + $play_pos) * $playfiles[$i]["audiolength"] / $playfiles[$i]["playtime"];

//output headers
header("Content-type: audio/mpeg");
// header("Content-type: audio/mp4");

//     header("icy-name: ".$settings["name"]);
//     header("icy-genre: ".$settings["genre"]);
//     header("icy-url: ".$settings["url"]);
//     header("icy-metaint: ".$settings["buffer_size"]);
//     header("icy-br: ".$settings["bitrate"]);
//     header("Content-Length: ".$settings["max_listen_time"] * $settings["bitrate"]); // * 128); //suppreses chuncked transfer-encoding

//play content
$old_buffer = substr(file_get_contents($settings["music_directory"].$playfiles[$i]["filename"]), $playfiles[$i]["audiostart"] + $track_pos, $playfiles[$i]["audiolength"] - $track_pos);
while(time() - $start_time < $settings["max_listen_time"]) {
    $i = ++$i % count($playfiles);
    $buffer = $old_buffer.substr(file_get_contents($settings["music_directory"].$playfiles[$i]["filename"]), $playfiles[$i]["audiostart"], $playfiles[$i]["audiolength"]);
        
    for($j = 0; $j < floor(strlen($buffer) / $settings["buffer_size"]); $j++) {
        echo substr($buffer, $j * $settings["buffer_size"], $settings["buffer_size"]).$metadata;
    }
    $old_buffer = substr($buffer, $j * $settings["buffer_size"]);

}

?>
