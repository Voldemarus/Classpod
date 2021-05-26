#  <#Title#>

Audio system for group and private lessons: Idea:
-
-
-
-
Use -
-
Design, develop a distributed application for iPhone and AirPods for personal and group lessons with music and instruction
Create virtual local network over both LTE and WiFi
Create audio streaming and control service to all participants
Two roles - a teacher(s) and student(s)
- Each role uses personal AirPods (Pro) and iPhones
case - cardio tennis:
Audio playback/broadcast:
- Teacher broadcasts class’ audio - spotify service - to all students
- Students can choose to:
- Listen/Mute the teachers’ audio stream
- Listen/Mute personal audio
- Note: Can this be done hands free: e.g. “Hey spintip play spotify, my
cardio playlist”
Instruction:
- The teacher can address the students individually or as a group:
- Use NLP to decide whether the audio is a broadcast to the group or unicast to a specific student:
- Broadcast to the group - NLP detects no key words, or names:
- Automatically lower music volume for all participants when system
detects instruction from the teacher:
- Instruction goes to all students
- Unicast to a student - NLP detects a keyword like the name of the student
- Instruction goes only to that student - music volume reduced only
on the stream toward that student. - Student’s response:
- Student’s airpods can establish a connection to the coach but not amongst each other
- Coach can hear all students, but students can’t hear each other.

Аудиосистема для групповых и индивидуальных занятий: Идея:
-
-
-
-
Использовать -
-
Дизайн, разработка распределенного приложения для iPhone и AirPods для личных и групповых занятий с музыкой и инструкциями.
Создайте виртуальную локальную сеть через LTE и WiFi
Создание сервиса потокового аудио и управления для всех участников
Две роли - учитель (и) и ученик (и)
- Каждая роль использует личные AirPods (Pro) и iPhone
чехол - кардио теннис:
Воспроизведение / трансляция аудио:
- Учитель транслирует аудиозаписи класса - услугу Spotify - всем учащимся
- Студенты могут выбрать:
- Слушайте / отключите аудиопоток учителей
- Слушайте / отключите личное аудио
- Примечание: можно ли это сделать без помощи рук: например, «Эй, spintip play spotify, мой
кардио-плейлист »
Инструкция:
- Учитель может обращаться к ученикам индивидуально или в группе:
- Используйте NLP, чтобы решить, является ли звук трансляцией для группы или одноадресной передачей конкретному учащемуся:
- Трансляция для группы - НЛП не определяет ни ключевых слов, ни имен:
- Автоматически понижать громкость музыки для всех участников, когда система
обнаруживает указание учителя:
- Инструктаж идет всем ученикам
- Одноадресная рассылка студенту - НЛП обнаруживает такое ключевое слово, как имя студента
- Обучение идет только этому ученику - уменьшается только громкость музыки
на ручье к этому ученику. - Ответ студента:
- Аэродромы учеников могут устанавливать связь с тренером, но не между собой.
- Тренер слышит всех учеников, но ученики не слышат друг друга.

  
  Водолазкий 19:28
  
  Я добавил DAO  и набросал начальную схему базы данных 

  1. Запуск в режиме учителя - публикуем сервис и ждем подписчиков. Когда приходит подписка, создаем запись вида Stнdent и устанавливаем ей сокет 

  По этому сокету будем с ней разговаривать 

  Надо сделать окошко в Teacher mode для отображения списка подписчиков 

  В DAO есть для этого метод. 


  2, Запуск в режиме ученика - идея зеркальная. Я сейчас как раз займусь

  Вместо публикации сервиса я реаизую поиск запущенных сервисов. При обнаржуении будет создаваться запись Teacher, которые тоже надо отображать на окошке режима студентов. Чтобы студент мог выбрать себе курс, в котором будет заниматься 

  Тебе нужно брать данные из DAO и, возможно, реализовать нотификато ри обновление при поступлении новых записей туда. 

# -------

Серверная часть публикует сервис, но я пока не доделал клиентский браузер, вернее написал вчера, но не доработал и не протестировал. 

Идея в сдеюущем. Бонжур в сереном режиме объявляет сервисы, которые могут быть обнаружен клиентом. К обнаржуенному сервису клиент может приуепиться, при этом клиент должен будет передать в сервер свои данные, и получить взамен полную информацию о сервисе - это как раз сущности Teacher и Student. 

Этот протокол мы допишем, я там уже написал пару методов в coreData сущностях 

сейчас надо сделать минимум - поиск и отображение сервисов на клиентской части. Я думаю сделать это сейчас как раз на мак части 

Пока я с этим вожусь, можешь посмотреть на настройки профиля студента и преподавателя, чтобы можно было сохранят в приложении личные данные. 

Тут нужна форма с профилем 


Spotify

Client ID :  78714228917241b8b0513804bb22cf2f

Client Secret 4267e80483584864aa2e4027c19410cb



AVPlayer 

Receiver Stream Radio 
https://www.youtube.com/watch?v=3tDJYbp8Ehk
https://www.youtube.com/watch?v=0x-byaeNqcw



