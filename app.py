from flask import Flask, request
 
from twilio.rest import TwilioRestClient
 
app = Flask(__name__)
 
# put your own credentials here 
ACCOUNT_SID = 'ACd40c2985cef18c673ab9b8d84480df72' 
AUTH_TOKEN = '975a637d0337c6f6b6c074cc117b4b69' 
 
client = TwilioRestClient(ACCOUNT_SID, AUTH_TOKEN)
 
@app.route('/sms', methods=['POST'])
def send_sms():
    message = client.messages.create(
        to=request.form['To'], 
        from_='+1 646-462-4347 ', 
        body=request.form['Body'],
    )
 
    return message.sid
 
if __name__ == '__main__':
	app.debug = True
	app.run()
