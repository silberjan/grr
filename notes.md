# Sample Request

rake db:seed

Einloggen: `POST /sessions`
Payload `{user: :user_id}`

Session abfragen: `/sessions/:sessionId?embed=user,permissions,features`

Jan Renz: issue key transactions
