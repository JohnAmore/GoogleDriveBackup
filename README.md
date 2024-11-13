# Automated Backup System (Google Drive)
Using [rclone](https://rclone.org), you can now automate backing up your Document/ files in Linux with your Google Drive account!

### Cron Job Automation
The cron job used for automation is set to back up your files every other day at midnight. At midnight, the backup script will automatically execute, compressing
all of your Document filles into one .zip folder, sending it to your Google Drive.

