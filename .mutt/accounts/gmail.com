
source ~/.mutt/accounts/common
source ~/.mutt/accounts/sidebar

set folder          =   "imaps://imap.gmail.com:993"
set realname        =   "Azat Khuzhin"
set spoolfile       =   "+INBOX"
set postponed       =   "+[Gmail]/Drafts"
# For trash to work, you need share it in Gmail Settings -> Labels for IMAP
set trash           =   "imaps://imap.gmail.com/[Gmail]/Trash"
set move            =   no
set include
set auto_tag        =   yes
set imap_keepalive = 900

# Gmail-style keyboard shortcuts
bind  index,pager a  group-reply
bind  index,pager c  mail
bind  generic     x  tag-entry      #Select Conversation
bind  index       x  tag-thread     #Select Conversation
bind  pager       x  tag-message    #Select Conversation
bind  index,pager s  flag-message   #Star a message
macro index,pager +  <save-message>=[Gmail]/Important<enter><enter> "Mark as important"
macro index,pager !  <save-message>=[Gmail]/Spam<enter><enter> "Report spam"
bind  index,pager a  group-reply    #Reply all
bind  index,pager \# delete-thread  #Delete
bind  index,pager l  copy-message   #Label
bind  index,pager v  save-message   #Move to
macro index,pager I  <set-flag>O    "Mark as read"
macro index,pager U  <clear-flag>O  "Mark as unread"
macro index,pager y  "<save-message>=[Gmail]/All Mail<enter><enter>" "Gmail archive message"
macro index,pager gl "<change-folder>"
macro index,pager gi "<change-folder>=INBOX<enter>" "Go to inbox"
macro index,pager ga "<change-folder>=[Gmail]/All Mail<enter>" "Go to all mail"
macro index,pager gs "<change-folder>=[Gmail]/Starred<enter>" "Go to starred messages"
macro index,pager gd "<change-folder>=[Gmail]/Drafts<enter>" "Go to drafts"
macro index,pager gt "<change-folder>=[Gmail]/Sent Mail<enter>" "Go to sent mail"

bind index u imap-fetch-mail
