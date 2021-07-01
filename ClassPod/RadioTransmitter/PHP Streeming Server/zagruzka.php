<?
// После знака вопроса и перед не оставлять пустых строк и пробелов!

$dirDB = $_SERVER["DOCUMENT_ROOT"]."/";
$dir = $dirDB."music/";

// zagruzka.php - в папке загрузки на сервере
// Загрузить файлы с каталогом PriceBC.bplist и все картинки
// удалить файлы старее 2 недель, которых нет в списке json images.json

session_start();

// Проверяем хэш
$hash = substr(hash('md5', "As".floor(date("U")/1000)."Tuda"), 0, 64);
$Key_Param = $_POST["Key_Param"];
$Key_Get_Info = $_POST["Key_Get_Info"];

//echo "---$Key_Param---";
//echo "------>".print_r($_FILES, true)."<--------\n\n";

if ($Key_Param == $hash) {
    
    if ($Key_Get_Info == "Key_Get_Info") {
	    // получить список файлов
		$array = array();
		$dir_files = glob(__dir__.'/music/*'); 
		if (count($dir_files) > 0) {
			foreach($dir_files as $file) {	
				$filename = basename($file);
				if (strlen($filename) > 0) {
					$array[$filename] = array(
						"filesize" => filesize($file),
						"filedate" => filemtime($file)
						);
				}
// 				$array[] = array(
// 					"filename" => basename($file),
// 					"filesize" => filesize($file),
// 					"filedate" => filemtime($file)
// 				);
			}
		} 
		$result = json_encode($array, JSON_UNESCAPED_UNICODE);
		echo $result;
	    exit;
    }
    
    //echo "------>".print_r($_FILES, true)."<--------\n\n";

    // удалим старый плейлист чтобы он пересоздался при следующем обращении плеера
    unlink("music.db");

    foreach ($_FILES['userfile']['error'] as $key => $error) {
        //echo "".$key." - ".$_FILES["userfile"]["name"][$key]."\r\n";
        if ($error == UPLOAD_ERR_OK) {
							$tmp_name = $_FILES["userfile"]["tmp_name"][$key];
							// basename() может спасти от атак на файловую систему;
							// может понадобиться дополнительная проверка/очистка имени файла
							$name = basename($_FILES["userfile"]["name"][$key]);
							//echo "-->".$name."<--\n";
							if ($name == "images.json") {
									delete_old_music($tmp_name);
							} else if ($name == "music.db") {
									move_uploaded_file($tmp_name, $dirDB.$name);
							} else {
									move_uploaded_file($tmp_name, $dir.$name);
							}
        } else {
            echo "Ошибка: ".$name."\n";
            exit();
        }
    }
	unlink("popravka.txt"); // Сбросить воспроизведение на ноль
    echo "OK";
    
} else {
    echo "errorhash";
}

function delete_old_music($json_file) {
	// Если файла из директории нет в полученном списке то удалим его, если он старее 14 дней // 86400*14

	$array_names_from_bb = json_decode(file_get_contents($json_file));

	// текущее время
	$time_sec = time();

    $dir_files = glob(__dir__.'/music/*'); 
    foreach($dir_files as $file) {
		if (!in_array(basename($file), $array_names_from_bb) & ($time_sec - filemtime($file)) > 1209600 ) { // 2592000
				unlink($file);
			//echo "Удаляем ".basename($file)." ".filemtime($file)."\n";
		} 
    }

}


// После знака вопроса и перед не оставлять пустых строк и пробелов!
?>