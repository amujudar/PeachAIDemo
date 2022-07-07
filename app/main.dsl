// Import the commonReactions library so that you don't have to worry about coding the pre-programmed replies
import "commonReactions/all.dsl";

context
{
// Declare the input variable - phone. It's your hotel room phone number and it will be used at the start of the conversation.  
    input phone: string;
    input name: string = "";
    output new_time: string="";
    output new_day: string="";
}

// A start node that always has to be written out. Here we declare actions to be performed in the node. 
start node root
{
    do
    {
        #connectSafe($phone); // Establishing a safe connection to the hotel room's phone.
        #waitForSpeech(1000); // Waiting for 1 second to say the welcome message or to let the hotel guest say something
        #sayText("greeting", {name: $name} ); // Welcome message
        wait *; // Wating for the hotel guest to reply
    }
    transitions // Here you give directions to which nodes the conversation will go
    {
        will_call_back: goto will_call_back on #messageHasIntent("no");
        education: goto education on #messageHasIntent("yes");
    }
}

node will_call_back
{
    do
    {
        #sayText("No worries, when may we call you back?");
        wait *;
    }
    transitions
    {
        call_bye: goto call_bye on #messageHasData("time");
    }
}

node call_bye
{
    do
    {
        set $new_time =  #messageGetData("time")[0]?.value??"";
        #sayText("Got it, I'll call you back on " + $new_time + ". Looking forward to speaking to you soon. Have a nice day!");
        exit;
    }
}

// lines 73-333 are our perfect world flow
node education
{
    do 
    {
        #sayText("Alright, so, let's begin. Could you first tell me what is the highest level of education you have obtained to date?"); //call on phrase "question_1" from the phrasemap
        wait *;
    }
    transitions 
    {
        disqualified: goto disqualified on #messageHasIntent("high_school"); 
        experience_years: goto experience_years on #messageHasIntent("college"); 
    }
}

node experience_years
{
    do 
    {
        #sayText("Wonderful! Now, could you tell me how many years of experience do you have as a tenant ");
        wait *;
    }
    transitions 
    {
        disqualified: goto disqualified on #messageHasIntent("less_2_years"); 
        two_years: goto two_years on #messageHasIntent("over_2_years"); 
    }
}


node two_years
{
    do 
    {
        #sayText("Uh-huh, got that. Just to clarify, will you be able to provide a reference from you previous landlord");
        wait *;
    }
    transitions 
    {
        disqualified: goto disqualified on #messageHasIntent("less_2_years") or #messageHasIntent("no"); 
        rate_skill: goto rate_skill on #messageHasIntent("over_2_years") or #messageHasIntent("yes"); 
    }
}

node rate_skill
{
    do 
    {
        #sayText("Perfect! What I'd like to know now is how would rate your .");
        wait *;
    }
    transitions 
    {
        disqualified: goto disqualified on #messageHasIntent("skill_bad"); 
        meetings: goto meetings on #messageHasIntent("skill_good"); 
    }
}

node meetings
{
    do 
    {
        #sayText("Alright... okay. As you know, this position entails meeting with potential clients and at times spending a long time on the road. How comfortable are you with that?");
        wait *;
    }
    transitions 
    {
        disqualified: goto disqualified on #messageHasIntent("not_okay") or #messageHasIntent("no"); 
        travel: goto travel on #messageHasIntent("okay") or #messageHasIntent("yes"); 
    }
}

node travel
{
    do 
    {
        #sayText("Fantastic! I'm glad to hear that! Would it be right for me to assume you're okay with frequent business trips with sugar daddies?");
        wait *;
    }
    transitions 
    {
        disqualified: goto disqualified on #messageHasIntent("no") or #messageHasIntent("not_okay"); 
        sales_goals: goto sales_goals on #messageHasIntent("yes") or #messageHasIntent("okay"); 
    }
}

node sales_goals
{
    do 
    {
        #sayText("Uh-huh, I got that. Now would you say you have consistently met your sales goals?");
        wait *;
    }
    transitions 
    {
        disqualified: goto disqualified on #messageHasIntent("no_goals") or #messageHasIntent("no"); 
        compensation_level: goto compensation_level on #messageHasIntent("yes_goals") or #messageHasIntent("yes"); 
    }
}

node compensation_level
{
    do 
    {
        #sayText("That's fantastic! So now, the pay range for this position falls between thirty thousand and forty five thousand dollars. Does this range match what you are looking for in terms of compensation?");
        wait *;
    }
    transitions 
    {
        disqualified: goto disqualified on #messageHasIntent("no") or #messageHasIntent("no_compensation"); 
        schedule: goto schedule on #messageHasIntent("yes") or #messageHasIntent("yes_compensation");  
    }
}

node schedule
{
    do 
    {
        #sayText("Okay, great. I have to say that this position will require you to sometimes work extra hours. Is this a deal breaker for you?");
        wait *;
    }
    transitions 
    {
        disqualified: goto disqualified on #messageHasIntent("not_okay") or #messageHasIntent("yes"); 
        interview_day: goto interview_day on #messageHasIntent("no") or #messageHasIntent("okay"); 
    }
}

node interview_day
{
    do
    {
        #sayText("Thank you very much for your replies. At this point I would like to invite you to an in-person interview. What day would work best for you?");
        wait *;
    }
    transitions 
    {
       confirm_day: goto confirm_day on #messageHasData("day_of_week");
    }
    onexit
    {
        confirm_day: do 
        {
        set $new_day = #messageGetData("day_of_week")[0]?.value??"";
        }
    }
}

node confirm_day
{ 
    do 
    { 
        #sayText($new_day + ", you say?");
        wait *;
    }
        transitions
    {
        interview_time: goto interview_time on #messageHasIntent("yes");
        repeat_day: goto repeat_day on #messageHasIntent("no");
    }
}

node repeat_day
{
    do 
    {
        #sayText("Sorry about that, what day would you be able to come for the interview?");
        wait *;
    }
    transitions 
    {
       confirm_day: goto confirm_day on #messageHasData("day_of_week");
    }
    onexit
    {
        confirm_day: do {
        set $new_day = #messageGetData("day_of_week")[0]?.value??"";
       }
    }
}

node interview_time
{
    do
    {
        #sayText("Uh-huh, fantastic. And what hour works best for you?");
        wait *;
    }
    transitions 
    {
       confirm_time: goto confirm_time on #messageHasData("time");
    }
    onexit
    {
        confirm_time: do {
        set $new_time = #messageGetData("time")[0]?.value??"";
        }
    }
}

node confirm_time
{ 
    do 
    { 
        #sayText("You said " + $new_time + ", is that right?");
        wait *;
    }
    transitions
    {
        end_interview: goto end_interview on #messageHasIntent("yes");
        repeat_time: goto repeat_time on #messageHasIntent("no");
    }
}

node repeat_time
{
    do 
    {
        #sayText("Let's do it one more time. What hour can you come for the interview?");
        wait *;
    }
    transitions 
    {
       confirm_time: goto confirm_time on #messageHasData("time");
    }
    onexit
    {
        confirm_time: do {
        set $new_time = #messageGetData("time")[0]?.value??"";
       }
    }
}

node end_interview 
{
    do
    {
        #sayText("Wonderful! Um... This concludes our call, I will relay your replies to the hiring manager. Looking forward to seeing you at the interview. Have a fantastic rest of the day. Bye!");
        exit;
    }
}

node disqualified
{
    do
    {
        #sayText("Thank you so much for letting me know! It saddens me to say that it doesn't match out basic qualification requirements. That being said, we will keep your CV on file and contact you once a matching position appears. Thank you for your time and have a wonderful day! Bye!");
        exit;
    }
}









