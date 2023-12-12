# alexa_automation_cli 

## FEATURES

- Uses alexa-remote-control under the hood to speak directly to Amazon Alexa's API
- Requires little to no Shell scripting skills, tasks are setup in plain English
- Allows Alexa to execute commands or groups of commands (called Functions or Books) similar to Routines in the Alexa app
- Setup/Modify schedules for all your Alexa Tasks
- Know What/When the next set of Books will run next (as well as the individual tasks in those Books)
- Get updated Sunrise, Sunset, and Current Weather conditions which can be incorporated into the scripts logic to determine what will happen next
- Allows for further integration of Arduino weather stations, and other IOT devices (would require some BASH scripting knowledge)

![image](https://github.com/meirlazar/alexa_automation_cli/assets/2780621/2d19e2b2-6c53-40f2-8e1c-684473ac3a2b)

                                            HAS THIS EVER HAPPENED TO YOU?
- Alexa misunderstanding you when your mouth is full, or while half asleep?
- Being forced to fake a different accent just so she can recognize what you think is proper English? 
- Trying to scream over Alexa's non-stop chatter, but it fails to make her stop and listen?
- You ask Alexa to turn on a light, you get an acknowledgement, but nothing happens...and now loud heavy metal music is playing upstairs?
- Asking Alexa to stop the music, just makes it louder and more metal... waking up your rotten children at 3am?
- You use the Routines in the Alexa app only to find that Alexa doesn't have a freaking clue what day or time it is at that critical time you need her.

**** GET RID OF THE MISCOMMUNICATIONS, RELYING ON ROUTINES THAT SOMETIMES FAILS, OR JUST SHOW OFF TO YOUR FRIENDS (I ASSUME NOTHING ABOUT YOUR SOCIAL LIFE) ****

## BASIC INSTALLATION INSTRUCTIONS

1. Follow the instructions for installing and configuring alexa-remote-control (https://github.com/thorsten-gehrig/alexa-remote-control) 
2. Clone this repository 
   ``` git clone https://github.com/meirlazar/alexa_automation_cli.git ```   
4. Modify the script to match your environment.
   ``` cd alexa_automation_cli ; vim alexa_automation.sh ```
6. Set the script as executable
   ``` chmod +x alexa_automation.sh ```
7. Run the script
   ``` ./alexa_automation.sh ```
8. Now you know what's happening and when.
9. Let the script do the talking and Alexa do the walking, and you do the chilling.

## DETAILED INSTRUCTIONS ON USAGE

- Aliases can be set for any smart device that you can control with Alexa for ease of use.
- Create/Modify the schedules at the bottom of the script to have Alexa run those Commands/Playbooks on the day and time you specify
- Add your zipcode to the weather functions to have the script get current weather conditions
- Optional: Integrate IOT weather stations into the script to differentiate between inside versus outside weather.
  Example of usage:
  Current Conditions: It's cold outside and it's cold inside the house.
  Run: AlexaDoThis set HouseThermostat to Heat. Wait 30 minutes. If house temp has not changed, AlexaDoThis set HouseThermostat off, AlexaDoThis turn on BedroomHeaters
   
