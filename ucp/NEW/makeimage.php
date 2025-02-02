<?php 
	function getAdminTitleFromIndex($index)
	{
		$ranks = array("Player", "Trial Admin", "Administrator", "Super Admin", "Lead Admin", "Head Admin", "Owner");
		return $ranks[$index];
	}
	
	function getDonatorTitleFromIndex($index)
	{
		$ranks = array("No", "Bronze" ,"Silver", "Gold", "Platinum", "Pearl", "Diamond", "Godly");
		return $ranks[$index];
	}
	
	function getStandingFromIndex($index)
	{
		$ranks = array("<em><font color='#66FF00'>In Good Standing</font></em>", "<em><font color='#FF0000'>Banned</font></em>");
		return $ranks[$index];
	}
	
	function getVACStandingFromIndex($index)
	{
		$ranks = array("<em><font color='#66FF00'>In Good Standing</font></em>", "<em><font color='#FF0000'>VAC Banned</font></em>");
		return $ranks[$index];
	}
?><?php
	date_default_timezone_set('UTC');
	if (!is_dir("cache"))
		mkdir("cache");

	function destroyCache()
	{
		$results = array();
		
		$handler = opendir("cache");
		
		while ($file = readdir($handler))
		{
			if ($file != '.' && $file !=  '..')
				unlink("cache/" . $file);
		}
		
		closedir($handler);
	}
	
	function writeCacheFile()
	{
		$cachefile = "cachefile.dat";
		$string = date("d") . "," . date("H");
		file_put_contents($cachefile, $string);
	}
?><?php
	$cachefile = "cachefile.dat";
	$hashid = $_GET["id"];
	$username = substr(base64_decode($hashid), 16);
	$filename = "cache/" . md5("vgrpscotlandsalt" . $username) . ".png";

	// should we regenerate the cache?
	
	// no cache file data =[
	if ( !file_exists($cachefile) )
	{
		writeCacheFile();
		destroyCache();
	}
	else if ( file_exists($cachefile) ) // we have a cache file
	{
		$data = file_get_contents($cachefile);
		$array = explode(",", $data);
		
		
		if ($array[0] != date("d") || $array[1] != date("H")) // out of date, rebuild cache
		{
			writeCacheFile();
			destroyCache();
		}
	}
	
	// check if we already generated one
	if ( file_exists($filename) )
	{
		header('Content-Type: image/png');
		$image = imagecreatefrompng($filename);
		
		$data = file_get_contents($cachefile);
		$array = explode(",", $data);
		
		$day = $array[0];
		$hour = $array[1];
		$month = date("m");
		$year = date("y");
		
		$white = imagecolorallocate($image, 255, 255, 255);
		$blue = imagecolorallocate($image, 0, 162, 232);
		imagestring($image, 2, 5, 35, "Generated From Cache (" . $day . "-" . $month . "-" . $year . "@" . $hour . ":00)", $blue);
		
		imagepng($image);
		imagedestroy($image);
		
	}
	else
	{
		include("config.php");
		$conn = mysql_pconnect($mysql_host, $mysql_user, $mysql_pass);
		mysql_select_db("mta", $conn);

		$width = 400;
		$height = 50;
		
		$escUsername = mysql_real_escape_string($username, $conn);

		$image = imagecreatetruecolor(400, 50);
		
		$orange = imagecolorallocate($image, 255, 194, 15);
		$white = imagecolorallocate($image, 255, 255, 255);
		$black = imagecolorallocate($image, 0, 0, 0);
		$blue = imagecolorallocate($image, 0, 162, 232);
		
		imagefill($image, 0, 0, $orange);
		
		// border
		imageline($image, 0, 0, $width-1, 0, $black);
		imageline($image, $width-1, 0, $width-1, $height, $black);
		imageline($image, 0, $height-1, $width-1, $height-1, $black);
		imageline($image, 0, 0, 0, $height-1, $black);
		
		
		// title
		imagestring($image, 2, 230, 35, "vGMTA - 87.238.173.138:22003", $blue);
		
		// SQL
		$result = mysql_query("SELECT id, admin, donator, friends FROM accounts WHERE username ='" . $escUsername . "' LIMIT 1", $conn);
		
		
		
		if (!$result || mysql_num_rows($result)==0)
		{
			header('Content-Type: image/png');
			$image = imagecreatetruecolor(400, 50);
		
			$orange = imagecolorallocate($image, 255, 194, 15);
			$white = imagecolorallocate($image, 255, 255, 255);
			$black = imagecolorallocate($image, 0, 0, 0);
			$blue = imagecolorallocate($image, 0, 162, 232);
			
			imagefill($image, 0, 0, $orange);
			
			// border
			imageline($image, 0, 0, $width-1, 0, $black);
			imageline($image, $width-1, 0, $width-1, $height, $black);
			imageline($image, 0, $height-1, $width-1, $height-1, $black);
			imageline($image, 0, 0, 0, $height-1, $black);
			
			
			// title
			imagestring($image, 4, 5, 0, "No Such User", $blue);
			imagepng($image);
			imagedestroy($image);

			exit;
		}
		
		$id = mysql_result($result, 0, 0);
		$admin = mysql_result($result, 0, 1);
		$donator = mysql_result($result, 0, 2);
		$friends = mysql_result($result, 0, 3);
		mysql_free_result($result);
		
		$result2 = mysql_query("SELECT COUNT(*), SUM(hoursplayed), SUM(money+bankmoney) FROM characters WHERE account = " . $id, $conn);
		$characters = mysql_result($result2, 0, 0);
		$hoursplayed = mysql_result($result2, 0, 1);
		$networth = mysql_result($result2, 0, 2);
		mysql_free_result($result2);
		
		$result3 = mysql_query("SELECT COUNT(*) FROM achievements WHERE account = " . $id, $conn);
		$achievements = mysql_result($result3, 0, 0);
		mysql_free_result($result3);
		
		imagestring($image, 4, 5, 0, $username . " (" . getAdminTitleFromIndex($admin) . ")", $blue);
		imagestring($image, 3, 7, 15, "Donator: " . getDonatorTitleFromIndex($donator), $black);
		imagestring($image, 3, 7, 25, "Characters: " . $characters, $black);
		imagestring($image, 3, 130, 15, "Hours Played: " . $hoursplayed, $black);
		imagestring($image, 3, 130, 25, "Net Worth: " . $networth . "$", $black);
		imagestring($image, 3, 280, 15, "Achievements: " . $achievements, $black);
		
		header('Content-type: image/png');
		imagepng($image, $filename);
		imagestring($image, 2, 5, 35, "Generated Live", $blue);
		imagepng($image);
		imagedestroy($image);
	}
?>