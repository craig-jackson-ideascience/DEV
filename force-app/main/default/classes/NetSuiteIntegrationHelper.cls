public with sharing class NetSuiteIntegrationHelper {
    public NetSuiteIntegrationHelper() {

    }

    public static HttpRequest addEndpointAndAuthHeader(HttpRequest req, Endpoints__c settings, Map<String, String> urlParams) {

		String nonce = String.valueOf(Crypto.getRandomLong());
		String timeStamp = String.valueOf(Integer.valueOf(DateTime.now().getTime() / 1000));
		String restMethod = req.getMethod()+'&';
		String encryptedUrl = EncodingUtil.urlEncode(settings.Endpoint__c, 'UTF-8') + '&deploy%3D1'; // &deploy=1
		
		// These values are hard-coded because they shouldn't need to change
		String signatureMethod = 'HMAC-SHA256';
		String version = '1.0';
		
		// concatMsgExample = 'PUT&https%3A%2F%2F1006702-sb3.restlets.api.netsuite.com%2Fapp%2Fsite%2Fhosting%2Frestlet.nl&deploy%3D1%26oauth_consumer_key%3Db9abc6d9c01005674d3ea0d2246c713c90c9893c8ddebecb7888787526206cc2%26oauth_nonce%3D'+nonce+'%26oauth_signature_method%3DHMAC-SHA256%26oauth_timestamp%3D'+timeStamp+'%26oauth_token%3Dd9407b102456d5b1a6f27eac129b2e7e7c65a66d36b924abd9e59f5a10398577%26oauth_version%3D1.0%26script%3D889';
		// The entire string is not going to be encoded. There are two & signs in the string that need to remain. 1st right at the beginning (PUT&http...), the second is the & right before deploy that you can see in the line above
		String encodedString = '';
		encodedString += '&oauth_consumer_key=' + settings.Consumer_Key__c;
		encodedString += '&oauth_nonce=' + nonce;
		encodedString += '&oauth_signature_method=' + signatureMethod;
		encodedString += '&oauth_timestamp=' + timeStamp;
		encodedString += '&oauth_token=' + settings.Access_Token__c;
		encodedString += '&oauth_version=' + version;

		String urlParamsString = '';
		for (String key : urlParams.keySet()) {
			String value = urlParams.get(key);
			urlParamsString += '&' + key + '=' + value;
		}

		encodedString += urlParamsString;
		System.debug('encodedString before encoding: ' + encodedString);
		encodedString = EncodingUtil.urlEncode(encodedString, 'UTF-8');

	
		String concatMsg = restMethod + encryptedUrl + encodedString;
		System.debug('concatMsg string: ' + concatMsg);
		
		// Create a string of the secrets provided.
		String concatSecret = settings.Consumer_Secret__c + '&' + settings.Token_Secret__c;
		// create a signature Blob, using the secrets to hash the concatMsg to get the signature. Will need to be converted to a string and then urlEncoded.
		Blob signatureBlob = Crypto.generateMac('HmacSHA256', Blob.valueOf(concatMsg), Blob.valueOf(concatSecret));
		// Converting the signature blob to a string
		String signature = EncodingUtil.base64Encode(signatureBlob);
		// Url encoding the signature before sending it off to netsuite
		signature = EncodingUtil.urlEncode(signature, 'UTF-8');
		System.debug('signature after method completion: '+ signature);

		String authHeader = 'OAuth realm="'+settings.Realm__c+'",oauth_consumer_key="'+settings.Consumer_Key__c+'",oauth_token="'+settings.Access_Token__c+'",oauth_signature_method="'+signatureMethod+'",oauth_timestamp="'+timeStamp+'",oauth_nonce="'+nonce+'",oauth_version="'+version+'",oauth_signature="'+signature+'"';
		
		req.setHeader('Authorization', authHeader);
		
		req.setEndpoint(settings.Endpoint__c + '?deploy=1' + urlParamsString);
		req.setTimeout(120000);

		return req;
	}

}