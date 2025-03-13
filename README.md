## Athan App
***

### Athan Timetable Data

For now, we manually copy time table from the East London Mosque website from the [**link here**](https://www.eastlondonmosque.org.uk/prayer-times).

It is tab separated data, just copy from the page and save it in the [**input folder**](https://github.com/manwar/athan-app/tree/master/input) in a file name `YYYY-MM.txt`.

### Generate Athan Time

The above time table then get parsed and saved into the [**output folder**](https://github.com/manwar/athan-app/tree/master/output) using [**the script**](https://github.com/manwar/athan-app/blob/master/bin/gen-timetable.pl).

      $ perl bin/gen-timetable.pl input/ output/

During the month of, say `March 2025`, the above command would pick source timetable `input/2025-03.txt` and generate the athan time in `output/2025-03.txt`.

The file in the `input/` folder contains data in the format as below:

      1    5:05	5:25	6:42	12:18	12:45	3:05	3:49	4:15	5:44	5:59	7:10	8:00
      2    5:03	5:23	6:40	12:18	12:45	3:06	3:51	4:15	5:46	6:01	7:12	8:00
      3    5:01	5:21	6:38	12:18	12:45	3:07	3:52	4:15	5:48	6:03	7:13	8:00

The application expects time in the format `YYYY-MM-DD HH:MI|F` or `YYYY-MM-DD HH:MI|R` per line.

After the run, it generates file in the `output/` folder in the format as below:

      2025-03-01 05:05|F
      2025-03-01 12:18|R
      2025-03-01 03:05|R
      2025-03-01 05:44|R
      2025-03-01 07:10|R

The last character `F` indicates the `Fajar` time and `R` means regular time.

### Athan App Script

The [**main script**](https://github.com/manwar/athan-app/blob/master/bin/play-athan.pl) is then run in the background to play the athan at appropriate time.

Currently it is running in the background manually as below:

      $ perl bin/play-athan.pl output/ athan/ &

The folder [**athan/**](https://github.com/manwar/athan-app/tree/master/athan) contains the mp3 sound of athan.

### Logging

By default application log in the `/tmp/athan-app.log` file.

The environment variable `ATHAN_VERBOSE` enables the logging of heartbeat every `10 seconds`.
