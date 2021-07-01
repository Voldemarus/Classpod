<?

$p = $_GET["type"];
$offset_from_current_time = $_GET["offset"]; // Установит сдвиг от начала с текущего времени
$continue_after_offset = $_GET["continue"]; // продолжить воспроизведение после сброса
if ($p != "mymusic") {
    echo "Not support parameters... Better Call Saul...";
    exit(13);
}

//in brouser type:  https://classpod.spintip.com/?type=mymusic

//set variables
$settings = array(
    'name' => 'Name radiostation',     // Название вашей радиостанции.
    'genre' => 'Electronic',         // Не обязательно должен быть в формате MP3, может быть любым.
    'url' => $_SERVER['HTTP_HOST'], // URL станции, автоматически генерируется PHP.
    'bitrate' => 128,                 // Битрейт передачи в кбит / с. Все аудио, но должны быть перекодированы до этого битрейта.
    'music_directory' => "music/",     // Папка, в которой находится звук.
    'database_file' => "music.db",     // Имя файла кэша метаданных аудио.
    'buffer_size' => 16384,         // Размер буфера ледяных данных, не очень важно.
                                    // Чем больше буфер, тем меньше обновлений текущего названия песни.
    'max_listen_time' => 14400,     // Максимальное время прослушивания пользователя в секундах. Установите 4 часа.
);


set_time_limit(0);

//load playlist

$playfiles = json_decode(file_get_contents($settings["database_file"]), true);

$total_playtime = 0;

//set playlist

$file_popravka = "popravka.txt";
$popravka = file_get_contents($file_popravka);
$start_time = microtime(true) - $popravka;

//sum playtime
foreach($playfiles as $playfile) {
    $total_playtime += $playfile["playtime"];
}

//calculate the current song
$play_pos = $start_time % $total_playtime;

if (!file_exists($file_popravka) && !$offset_from_current_time && !$continue_after_offset) {
    // Если фала не было, то сбросим на ноль позицию
    $offset_from_current_time = 0.0001;
    $continue_after_offset = 1;
}

if ($offset_from_current_time > 0) {
    // сбросить воспроизведение на начало - offset_from_current_time
    $start_time = microtime(true);
    $popravka = ($start_time - $offset_from_current_time) % $total_playtime;
    file_put_contents($file_popravka, $popravka);
    if (!$continue_after_offset) {
        echo "OK";
        exit;
    }
    $start_time = microtime(true) - $popravka;
    $play_pos = $start_time % $total_playtime;
}

foreach($playfiles as $i=>$playfile) {
    $play_sum += $playfile["playtime"];
    if ($play_sum > $play_pos) {
        break;
    }
}
$track_pos = ($playfiles[$i]["playtime"] - $play_sum + $play_pos) * $playfiles[$i]["audiolength"] / $playfiles[$i]["playtime"];

//output headers
header("Content-type: audio/mpeg");
// header("Content-type: audio/mp4");

    header("icy-name: ".$settings["name"]);
//     header("icy-genre: ".$settings["genre"]);
//     header("icy-url: ".$settings["url"]);
    header("icy-metaint: ".$settings["buffer_size"]);
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
