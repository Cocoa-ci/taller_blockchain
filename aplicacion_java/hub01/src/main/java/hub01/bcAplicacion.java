package hub01;

import java.nio.file.Paths;
import java.security.PrivateKey;
import java.util.Properties;
import java.util.Set;

import org.hyperledger.fabric.gateway.Identities;
import org.hyperledger.fabric.gateway.Identity;
import org.hyperledger.fabric.gateway.Wallet;
import org.hyperledger.fabric.gateway.Wallets;
import org.hyperledger.fabric.gateway.X509Identity;
import org.hyperledger.fabric.sdk.Enrollment;
import org.hyperledger.fabric.sdk.User;
import org.hyperledger.fabric.sdk.security.CryptoSuite;
import org.hyperledger.fabric.sdk.security.CryptoSuiteFactory;
import org.hyperledger.fabric_ca.sdk.EnrollmentRequest;
import org.hyperledger.fabric_ca.sdk.HFCAClient;
import org.hyperledger.fabric_ca.sdk.RegistrationRequest;

public class bcAplicacion {

	// ALWAYS UPDATE pem using autogenerated connection-org1.json in energy-network !!!!!
	public static String CONNECTION = "";
	public static String USER = "";
	public static String CHANNEL = "";
	public static String CONTRACT = "";
	public static String PEM_FILE = "";
	public static String URL = "";
	public static String AS_LOCALHOST = "";
	
	private static Rest_API_BC myBCexplorer; 

	static {
		System.setProperty("org.hyperledger.fabric.sdk.service_discovery.as_localhost", AS_LOCALHOST);
	}

	public static void main(String[] args) throws Exception {
	    
        System.out.println( "Setting up blockchain explorer " );

        CONNECTION = Configuration.getInstance().getProperty(Configuration.CONNECTION);
        USER = Configuration.getInstance().getProperty(Configuration.USER);
        CHANNEL = Configuration.getInstance().getProperty(Configuration.CHANNEL);
        CONTRACT = Configuration.getInstance().getProperty(Configuration.CONTRACT);
        PEM_FILE = Configuration.getInstance().getProperty(Configuration.PEM_FILE);
        URL = Configuration.getInstance().getProperty(Configuration.URL);
        AS_LOCALHOST = Configuration.getInstance().getProperty(Configuration.AS_LOCALHOST);
        
        
        System.out.println( " CONNECTION   : " + CONNECTION);
        System.out.println( " USER         : " + USER);
        System.out.println( " CHANNEL      : " + CHANNEL);
        System.out.println( " CONTRACT     : " + CONTRACT);
        System.out.println( " PEM_FILE     : " + PEM_FILE);
        System.out.println( " URL          : " + URL);
        System.out.println( " AS_LOCALHOST : " + AS_LOCALHOST);
        
        
        // Enroll admin
        enrollAdmin();
		// Wait for 10 seconds
    	try {
			Thread.sleep(10000);
			System.out.println( " =========== > Finished enrollment .... wait for final settings " );
		} catch (InterruptedException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
    	
        
        // Register User
    	registerUser();
		// Wait for 10 seconds
    	try {
			Thread.sleep(10000);
			System.out.println( " =========== > Finished registering user .... wait for final settings " );
		} catch (InterruptedException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
        
        // Setting REST API for blockchain explorer
        myBCexplorer = new Rest_API_BC(CONNECTION, USER, CHANNEL, CONTRACT);
        myBCexplorer.start();
        System.out.println( "Setting up blockchain explorer done!" );
        
	}

	public static void enrollAdmin() throws Exception {
		// Create a CA client for interacting with the CA.
		Properties props = new Properties();
		props.put("pemFile",PEM_FILE);
		props.put("allowAllHostNames", "true");
		HFCAClient caClient = HFCAClient.createNewInstance(URL, props);
		CryptoSuite cryptoSuite = CryptoSuiteFactory.getDefault().getCryptoSuite();
		caClient.setCryptoSuite(cryptoSuite);

		// Create a wallet for managing identities
		Wallet wallet = Wallets.newFileSystemWallet(Paths.get("wallet"));

		// Check to see if we've already enrolled the admin user.
        if (wallet.get("admin") != null) {
            System.out.println("An identity for the admin user \"admin\" already exists in the wallet");
            return;
        }

        // Enroll the admin user, and import the new identity into the wallet.
        final EnrollmentRequest enrollmentRequestTLS = new EnrollmentRequest();
        enrollmentRequestTLS.addHost("localhost");
        enrollmentRequestTLS.setProfile("tls");
        Enrollment enrollment = caClient.enroll("admin", "adminpw", enrollmentRequestTLS);
        Identity user = Identities.newX509Identity("Org1MSP", enrollment);
        //.createIdentity("Org1MSP", enrollment.getCert(), enrollment.getKey());
        wallet.put("admin", user);
		System.out.println("Successfully enrolled user \"admin\" and imported it into the wallet");		
	}
	
	public static void registerUser() throws Exception {

		// Create a CA client for interacting with the CA.
		Properties props = new Properties();
		props.put("pemFile",PEM_FILE);
		//"../../energy-network/crypto-config/peerOrganizations/org1.government.com/ca/ca.org1.government.com-cert.pem");
		props.put("allowAllHostNames", "true");
		HFCAClient caClient = HFCAClient.createNewInstance(URL, props);
		CryptoSuite cryptoSuite = CryptoSuiteFactory.getDefault().getCryptoSuite();
		caClient.setCryptoSuite(cryptoSuite);

		// Create a wallet for managing identities
		Wallet wallet = Wallets.newFileSystemWallet(Paths.get("wallet"));

		// Check to see if we've already enrolled the user.
		if (wallet.get(USER) != null) {
			System.out.println("An identity for the user " + USER + " already exists in the wallet");
			return;
		}

		X509Identity adminIdentity = (X509Identity)wallet.get("admin");
		if (adminIdentity == null) {
			System.out.println("\"admin\" needs to be enrolled and added to the wallet first");
			return;
		}
		User admin = new User() {

			@Override
			public String getName() {
				return "admin";
			}

			@Override
			public Set<String> getRoles() {
				return null;
			}

			@Override
			public String getAccount() {
				return null;
			}

			@Override
			public String getAffiliation() {
				return "org1.department1";
			}

			@Override
			public Enrollment getEnrollment() {
				return new Enrollment() {

					@Override
					public PrivateKey getKey() {
						return adminIdentity.getPrivateKey();
					}

					@Override
					public String getCert() {
						return Identities.toPemString(adminIdentity.getCertificate());
					}
				};
			}

			@Override
			public String getMspId() {
				return "Org1MSP";
			}

		};
		
		// Register the user, enroll the user, and import the new identity into the wallet.
		RegistrationRequest registrationRequest = new RegistrationRequest(USER);
		registrationRequest.setAffiliation("org1.department1");
		registrationRequest.setEnrollmentID(USER);
		String enrollmentSecret = caClient.register(registrationRequest, admin);
		Enrollment enrollment = caClient.enroll(USER, enrollmentSecret);
		Identity user = Identities.newX509Identity("Org1MSP", enrollment);
		// Identity user = Identities.newX509Identity("Org1MSP", adminIdentity.getCertificate(), adminIdentity.getPrivateKey());
		//Identity user = Identity.createIdentity("Org1MSP", enrollment.getCert(), enrollment.getKey());
		wallet.put(USER, user);
		System.out.println("Successfully enrolled user " + USER + " and imported it into the wallet");
	}
	
}
