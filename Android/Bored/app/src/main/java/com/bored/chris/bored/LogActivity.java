package com.bored.chris.bored;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.UserProfileChangeRequest;

public class LogActivity extends AppCompatActivity {

    private FirebaseAuth mAuth;

    private Boolean logType = false;

    private EditText usernameET;
    private EditText passwordET;
    private EditText displayNameET;
    private Button loginSignupButton;
    private Button switchTypeButton;

    private ProgressDialog loading;

    private FirebaseAuth.AuthStateListener mAuthListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_log);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        mAuth = FirebaseAuth.getInstance();

        loading = new ProgressDialog(this);
        loading.setCancelable(false);
        loading.setProgressStyle(ProgressDialog.STYLE_SPINNER);

        usernameET = (EditText) findViewById(R.id.editText);
        passwordET = (EditText) findViewById(R.id.editText2);
        displayNameET = (EditText) findViewById(R.id.editText3);
        loginSignupButton = (Button) findViewById(R.id.button);
        loginSignupButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (logType){
                    if (usernameET.getText().toString().trim().length() != 0 && passwordET.getText().toString().trim().length() != 0){
                        logUser(usernameET.getText().toString(), passwordET.getText().toString());
                    }
                    else {
                        Toast.makeText(LogActivity.this, "Please fill all fields", Toast.LENGTH_SHORT).show();
                    }
                }
                else {
                    if (usernameET.getText().toString().trim().length() != 0 && passwordET.getText().toString().trim().length() != 0 &&
                            displayNameET.getText().toString().trim().length() != 0){
                        if (passwordET.getText().toString().trim().length() > 5){
                            createUser(usernameET.getText().toString(), passwordET.getText().toString());
                        }
                        else {
                            Toast.makeText(LogActivity.this, "Password must be 6 or more characters", Toast.LENGTH_SHORT).show();
                        }

                    }
                    else {
                        Toast.makeText(LogActivity.this, "Please fill all fields", Toast.LENGTH_SHORT).show();
                    }
                }
            }
        });

        switchTypeButton = (Button) findViewById(R.id.button2);
        switchTypeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                switchType();
            }
        });

        switchType();

        mAuthListener = new FirebaseAuth.AuthStateListener() {
            @Override
            public void onAuthStateChanged(@NonNull FirebaseAuth firebaseAuth) {
                final FirebaseUser user = firebaseAuth.getCurrentUser();
                if (user != null) {
                    // User is signed in

                    Log.e("onAuthStateChanged:", user.getUid());

                    if (displayNameET.getVisibility() != View.GONE){
                        UserProfileChangeRequest profileUpdates = new UserProfileChangeRequest.Builder()
                                .setDisplayName(displayNameET.getText().toString())
                                .build();

                        user.updateProfile(profileUpdates)
                                .addOnCompleteListener(new OnCompleteListener<Void>() {
                                    @Override
                                    public void onComplete(@NonNull Task<Void> task) {
                                        if (task.isSuccessful()) {
                                            Log.e("onComplete: ", "UPDATED");
                                            loading.dismiss();
                                            goToHomeScreen();
                                            usernameET.setText("");
                                            passwordET.setText("");
                                            displayNameET.setText("");
                                        }
                                    }
                                });
                    }
                    else {
                        loading.dismiss();
                        usernameET.setText("");
                        passwordET.setText("");
                        goToHomeScreen();
                    }

                } else {
                    // User is signed out
                    Log.e("onAuthStateChanged:", "signedOut");
                }
            }
        };
    }

    @Override
    public void onStart() {
        super.onStart();
        mAuth.addAuthStateListener(mAuthListener);
    }

    @Override
    public void onStop() {
        super.onStop();
        if (mAuthListener != null) {
            mAuth.removeAuthStateListener(mAuthListener);
        }
    }

    private void goToHomeScreen(){
        Intent intent = new Intent(LogActivity.this, MainActivity.class);
        intent.putExtra("name", usernameET.getText().toString());
        startActivityForResult(intent, 0);
    }

    private void switchType(){
        if (logType){
            //Switch to Sign
            this.logType = false;
            setTitle("Sign Up");
            displayNameET.setVisibility(View.VISIBLE);
            loginSignupButton.setText("Sign Up");
            switchTypeButton.setText("Already have an account? Log in!");
        }
        else {
            this.logType = true;
            setTitle("Log In");
            displayNameET.setVisibility(View.GONE);
            loginSignupButton.setText("Log In");
            switchTypeButton.setText("Don't have an account? Sign up!");
        }

    }

    private void logUser(String username, String password){
        loading.setMessage("Logging on...");
        loading.show();
        mAuth.signInWithEmailAndPassword(username, password)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        Log.d("signInWithEmail:", String.valueOf(task.isSuccessful()));

                        if (!task.isSuccessful()) {
                            Log.w("signInWithEmail:", task.getException());
                            Toast.makeText(LogActivity.this, "Incorrect Username/Password", Toast.LENGTH_SHORT).show();
                            loading.dismiss();
                        }
                    }
                });
    }

    private void createUser(String username, String password){
        loading.setMessage("Signing up...");
        loading.show();
        mAuth.createUserWithEmailAndPassword(username, password)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        Log.e("createUser:", String.valueOf(task.isSuccessful()));

                        if (!task.isSuccessful()) {
                            Toast.makeText(LogActivity.this, "Sign up Failed", Toast.LENGTH_SHORT).show();
                            Log.e("createUser:", task.toString());
                            loading.dismiss();
                        }

                    }
                });
    }

}
