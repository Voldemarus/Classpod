<?

$p = $_GET["type"];
if ($p != "mymusic") {
    echo "Not support parameters... Better Call Saul...";
    exit(13);
}

// Исходники: https://sourceforge.net/projects/getid3/

//in brouser type:  https://classpod.ildd.ru/

//set variables

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

if(!file_exists($settings["database_file"])) {
    $filenames = array_slice(scandir($settings["music_directory"]), 2);
    foreach($filenames as $filename) {
        $id3 = $getID3->analyze($settings["music_directory"].$filename);
//                 echo "->".$id3["playtime_seconds"]."<--";
// exit;

//         if($id3["fileformat"] == "mp3") {
            $playfile = array(
                "filename" => $id3["filename"],
                "filesize" => $id3["filesize"],
                "playtime" => $id3["playtime_seconds"],
                "audiostart" => $id3["avdataoffset"],
                "audioend" => $id3["avdataend"],
                "audiolength" => $id3["avdataend"] - $id3["avdataoffset"],
                "artist" => $id3["tags"]["id3v2"]["artist"][0],
                "title" => $id3["tags"]["id3v2"]["title"][0]
            );
            if(empty($playfile["artist"]) || empty($playfile["title"])) {
                list($playfile["artist"], $playfile["title"]) = explode(" - ", substr($playfile["filename"], 0 , -4));
            }
            $playfiles[] = $playfile;
//         }
    }

    file_put_contents($settings["database_file"], serialize($playfiles));
} else {
    $playfiles = unserialize(file_get_contents($settings["database_file"]));
}

//user agents
$icy_data = false;
foreach(array("iTunes", "VLC", "Winamp") as $agent)
    if(substr($_SERVER["HTTP_USER_AGENT"], 0, strlen($agent)) == $agent)
        $icy_data = true;

//set playlist
$start_time = microtime(true);
srand($settings["randomize_seed"]);
shuffle($playfiles);

//sum playtime
foreach($playfiles as $playfile)
    $total_playtime += $playfile["playtime"];

//calculate the current song
$play_pos = $start_time % $total_playtime;
foreach($playfiles as $i=>$playfile) {
    $play_sum += $playfile["playtime"];
    if($play_sum > $play_pos)
        break;
}
$track_pos = ($playfiles[$i]["playtime"] - $play_sum + $play_pos) * $playfiles[$i]["audiolength"] / $playfiles[$i]["playtime"];



// echo "artist: [".$playfile["artist"]."]<br>\n";
// echo "title: [".$playfile["title"]."]<br>\n";
//
// echo "icy-name: [".$settings["name"]."]<br>\n";
// echo "icy-genre: [".$settings["genre"]."]<br>\n";
// echo "icy-url: [".$settings["url"]."]<br>\n";
// echo "icy-metaint: [".$settings["buffer_size"]."]<br>\n";
// echo "icy-br: [".$settings["bitrate"]."]<br>\n";
// echo "max_listen_time: [".$settings["max_listen_time"]."]<br>\n";
// // echo "max_listen_time: [".$settings["max_listen_time"]."]<br>\n";
// echo "Content-Length: [".($settings["max_listen_time"] * $settings["bitrate"] * 128)."]<br>\n";
// exit;
//
//output headers
header("Content-type: audio/mpeg");
// header("Content-type: audio/mp4");

if($icy_data) {
    header("icy-name: ".$settings["name"]);
    header("icy-genre: ".$settings["genre"]);
    header("icy-url: ".$settings["url"]);
    header("icy-metaint: ".$settings["buffer_size"]);
    header("icy-br: ".$settings["bitrate"]);
    header("Content-Length: ".$settings["max_listen_time"] * $settings["bitrate"]); // * 128); //suppreses chuncked transfer-encoding
}

//play content
$o = $i;
$old_buffer = substr(file_get_contents($settings["music_directory"].$playfiles[$i]["filename"]), $playfiles[$i]["audiostart"] + $track_pos, $playfiles[$i]["audiolength"] - $track_pos);
while(time() - $start_time < $settings["max_listen_time"]) {
    $i = ++$i % count($playfiles);
    $buffer = $old_buffer.substr(file_get_contents($settings["music_directory"].$playfiles[$i]["filename"]), $playfiles[$i]["audiostart"], $playfiles[$i]["audiolength"]);
        
    for($j = 0; $j < floor(strlen($buffer) / $settings["buffer_size"]); $j++) {
        if($icy_data) {
            if($i == $o + 1 && ($j * $settings["buffer_size"]) <= strlen($old_buffer))
                $payload = "StreamTitle='{$playfiles[$o]["artist"]} - {$playfiles[$o]["title"]}';".chr(0);
            else
                $payload = "StreamTitle='{$playfiles[$i]["artist"]} - {$playfiles[$i]["title"]}';".chr(0);

            $metadata = chr(ceil(strlen($payload) / 16)).$payload.str_repeat(chr(0), 16 - (strlen($payload) % 16));
        }
        echo substr($buffer, $j * $settings["buffer_size"], $settings["buffer_size"]).$metadata;
    }
    $o = $i;
    $old_buffer = substr($buffer, $j * $settings["buffer_size"]);
}
?>
