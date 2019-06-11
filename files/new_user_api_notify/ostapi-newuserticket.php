#!/usr/bin/php -q
<?php
#
# Configuration: Enter the url and key. That is it.
#  url => URL to api/task/cron e.g #  http://yourdomain.com/support/api/tickets.json
#  key => API's Key (see admin panel on how to generate a key)
#  $data add custom required fields to the array.
#
#  Originally authored by jared@osTicket.com
#  Modified by ntozier@osTicket / tmib.net

// If 1, display things to debug.
$debug="0";

// You must configure the url and key in the array below.
$config = array(
    'url'=> "{{ salt.pillar.get('pwm:lookup:osturl') }}/api/http.php/tickets.json",  // URL to site.tld/api/tickets.json
    'key'=> '{{ salt.pillar.get("pwm:lookup:ostapikey") }}'  // API Key goes here
);
# NOTE: some people have reported having to use "http://your.domain.tld/api/http.php/tickets.json" instead.

if($config['url'] === 'http://your.domain.tld/api/tickets.json') {
    echo "<p style=\"color:red;\"><b>Error: No URL</b><br>You have not configured this script with your URL!</p>";
    echo "Please edit this file ".__FILE__." and add your URL at line 18.</p>";
    die();
}

if(IsNullOrEmptyString($config['key']) || ($config['key'] === 'PUTyourAPIkeyHERE'))  {
    echo "<p style=\"color:red;\"><b>Error: No API Key</b><br>You have not configured this script with an API Key!</p>";
    echo "<p>Please log into osticket as an admin and navigate to: Admin panel -> Manage -> Api Keys then add a new API Key.<br>";
    echo "Once you have your key edit this file ".__FILE__." and add the key at line 19.</p>";
    die();
}

# Fill in the data for the new ticket, this will likely come from $_POST.
# NOTE: your variable names in osT are case sensiTive.
# So when adding custom lists or fields make sure you use the same case

$message = '<html><body style="font-family: Helvetica, Arial, san-serif; font-size:12pt;"><p>';
$message .= 'Someone just created a new {{ salt.pillar.get("pwm:lookup:envirname") }} account that needs approval.<br>';
$message .= 'The following new account was created:<br><br>';
$message .= '__username__ created an account at __time__ GMT from the following IP address: __ip__<br><br> ';
$message .= 'The account is enabled but in the AwaitingVerification OU, please confirm the account justification with the account manager, move the account to the Users OU, and send the new user the appropriate notification.<br><br>';
$message .= 'Note - Ticket created via API from PWM.</p>';

$data = array(
    'name'      =>      'The PWM via API',  // from name aka User/Client Name
    'email'     =>      '{{ salt.pillar.get("pwm:lookup:emailfrompwm") }}',  // from email aka User/Client Email
    'subject'   =>      'NEW USER: __username__ created an account in {{ salt.pillar.get("pwm:lookup:envirname") }}',  // test subject, aka Issue Summary
    'message'   =>      "data:text/html;charset=utf-8,$message", //the double quotes are so $message will be handled by php
    'topicId'   =>      '1', // the help Topic that you want to use for the ticket
    'attachments' => array()
);

# more fields are available and are documented at:
# https://github.com/osTicket/osTicket-1.8/blob/develop/setup/doc/api/tickets.md

if($debug=='1') {
    print_r($data);
    die();
}

#pre-checks
function_exists('curl_version') or die('CURL support required');
function_exists('json_encode') or die('JSON support required');

#set timeout
set_time_limit(30);

#curl post
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $config['url']);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_USERAGENT, 'osTicket API Client v1.8');
curl_setopt($ch, CURLOPT_HEADER, FALSE);
curl_setopt($ch, CURLOPT_HTTPHEADER, array( 'Expect:', 'X-API-Key: '.$config['key']));
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, FALSE);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
$result=curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($code != 201)
    die('Unable to create ticket: '.$result);

$ticket_id = (int) $result;
#$toconsole = "Ticket number ".$ticket_id." created.\n";
#echo $toconsole;

# Continue onward here if necessary. $ticket_id has the ID number of the
# newly-created ticket

function IsNullOrEmptyString($question){
    return (!isset($question) || trim($question)==='');
}
?>
