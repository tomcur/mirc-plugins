; Author: Thomas Churchman
; https://github.com/Beskhue
; 
; Simple quality of life extensions 
; to mIRC's default menus.
; 
; Copyright (c) 2016 Thomas Churchman
; 
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
; 
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

alias _inviteNick {
  if ($1 == begin) { RETURN }
  if ($1 == end) { RETURN }
  var %chan = $chan($1), %nick = $2
  IF (%chan ischan) { RETURN %chan :invite %nick %chan }
}

menu nicklist,query {
  Open Query Window: /query $$1
  Send Channel Invite
  .$submenu($_inviteNick($1,[ $+ [ $$1 ] ]))
  Whois: /whois $$1
  CTCP
  .Ping:CTCP $$1 PING
  .Time:CTCP $$1 TIME
  .Version:CTCP $$1 VERSION
}

menu status,query,channel {
  -
  Clear Buffer: clear
}
