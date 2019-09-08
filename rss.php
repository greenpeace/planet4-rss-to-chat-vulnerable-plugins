<?php

date_default_timezone_set('Europe/Amsterdam');
require_once "simplepie/autoloader.php";

//$file = "latestfeed";
//$previous_timestamp = file_get_contents( $file );
//$previous_timestamp = '';
$previous_timestamp = $_ENV["LAST_RSS_TIMESTAMP"];

$new_last_timestamp = $previous_timestamp;
echo "the previous timestamp was $previous_timestamp <br> \n";

$url_hangout    = $_ENV["GOOGLE_CHAT_ROOM_VULNERABLE_PLUGINS_URL"];
$url_rocketchat = $_ENV["ROCKETCHAT_ROOM_HOOK_URL"];
$url            = 'https://wpvulndb.com/feed.xml';


//$urls = array('foxnews.com','cnn.com','digg.com');
$feed = new SimplePie();
$feed->set_feed_url($url);
$feed->set_cache_duration(100);
$feed->init();

rprint($feed);

foreach ( $feed->get_items() as $item) {

	$title       = $item->get_title();
	$link        = $item->get_link();
	$pubdate     = $item->get_date();
	$timestamp   = strtotime( $pubdate );

	$kitem = array(
		'title'       => $title,
		'link'        => $link,
		'pubdate'     => $pubdate,
		'timestamp'   => $timestamp,
	);

	$kitems[ $timestamp ] = $kitem;
}
ksort($kitems);

//rprint($kitems);


foreach ($kitems as $timestamp => $item) {
	$title       = $item['title'];
	$link        = $item['link'];
	$pubdate     = date( 'l jS \of F Y h:i:s A', $timestamp );
	echo "----------------- \n";
	echo "The previous timestamp was $previous_timestamp . The items timestamp is $timestamp <br> \n";

	if ( $previous_timestamp < $timestamp ) {
		$text = '*' . $title . "* \n";
		$text .= $pubdate . " \n";

		//echo "the latest timestamp is: $timestamp <br>";
		$new_last_timestamp = $timestamp;
		echo "Sending vulnerability for $title <br>\n";

		// Send the data to google hangout chat
		$post_data = array(
			'text' => $text,
		);
		$result = '';
		$result = httpJsonPost( $url_hangout, $post_data );
		if ( false === $result ) {
			/* Handle error */
			echo 'we had an errror';
		}

		// Send the data to RocketChat
		$post_data = array(
			'text' => $text,
			'link' => $link,
		);
		$result = '';
		$result = httpJsonPost( $url_rocketchat, $post_data );
		if ( false === $result ) {
			/* Handle error */
			echo 'we had an errror';
		}

		//var_dump($result);

	} else {
		echo "sending nothing <br>\n";
	}
}


$env_var_script = shell_exec("/app/set_circle_envvar.sh LAST_RSS_TIMESTAMP $new_last_timestamp");
echo "---- We will set env variable  ---";
echo $env_var_script;
echo "---- Env variable settigns end ---";


function httpJsonPost($url, $data) {
	$ch        = curl_init( $url );
	$json_data = json_encode( $data, JSON_FORCE_OBJECT );
	//echo "the json data is: " . $json_data . "<br>";
	curl_setopt_array($ch, array(
		CURLOPT_POST => true,
		CURLOPT_RETURNTRANSFER => true,
		CURLOPT_HTTPHEADER => array(
			'Content-Type: application/json',
		),
		CURLOPT_POSTFIELDS => $json_data,
	));

	// Send the request
	$response = curl_exec($ch);

	// Check for errors
	if($response === FALSE){
		die(curl_error($ch));
	}
	return $response;
}



function rprint($var) {
	echo "<pre> \n";
	print_r($var);
	echo "</pre> \n";
}
