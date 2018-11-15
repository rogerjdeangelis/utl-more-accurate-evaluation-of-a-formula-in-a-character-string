More accurate evaluation of a formula in a character string

Evaluate the character string '(13.1**3)**(1/3)' to 15 decimal places
Answer should be RES=13.100000000000000

github
https://tinyurl.com/yaazbchd
https://github.com/rogerjdeangelis/utl-more-accurate-evaluation-of-a-formula-in-a-character-string

  Three Solutions
  ---------------

   1. Good Approximation

      res=resolve('%sysevalf((13.1**3)**(1/3)')');
      RES=13.099999999999600

      Art
      https://communities.sas.com/t5/user/viewprofilepage/user-id/13711


   2. Exact to 15 places dosubl save and read hex16.
      RES=13.100000000000000

   3. Exact to 15 places dosubl shared storage.
      RES=13.100000000000000

SAS Forum
https://tinyurl.com/ydb6olgw
https://communities.sas.com/t5/SAS-Programming/Is-there-a-function-that-performs-a-calculation-described-in/m-p/513351


INPUT
=====

   '(13.1**3)**(1/3)'

OUTPUTS
-------

1. Good Approximation

   RES=13.099999999999600

2. Exact to 15 places dosubl save and read hex16.

   RES=13.100000000000000

3. Exact to 15 places dosubl shared storage.

   RES=13.100000000000000


PROCESS
=======

1. Good Approximation
---------------------
data test;
  input formula $25.;
  res=resolve('%sysevalf('||formula||')');
  put res= 19.15;
cards4;
(13.1**3)**(1/3)
;;;;
run;quit;

RES=13.0999999999996


2. Exact to 15 places dosubl save and read hex16.
-------------------------------------------------

%symdel equx cc / nowarn;
data want;

  input equ $25.;

  call symputx('equ',equ);

  rc=dosubl('
    data _null_;
      call symputx("equx",put(&equ,hex16.),"G");
    run;quit;
  ');

   res = input(symgetc('equx'),hex16.);
   put res= 19.15;

cards4;
(13.1**3)**(1/3)
;;;;
run;quit;

RES=13.100000000000000


3. Exact to 15 places dosubl shared storage.
--------------------------------------------

%macro commonn(var,action=init);
   %if %upcase(&action) = INIT %then %do;
      retain &var 0;
      call symputx("varadr",put(addrlong(&var.),hex16.),"G");
   %end;
   %else %if "%upcase(&action)" = "PUT" %then %do;
      call pokelong(put(&var,rb8.),"&varadr."x,8,8);
   %end;
   %else %if "%upcase(&action)" = "GET" %then %do;
      &var = input(peekclong("&varadr."x,8),rb8.);
   %end;
%mend commonn;

data want;

  %commonn(result,action=INIT);

  input equ $25.;

  call symputx('equ',equ);

      rc=dosubl('
        data _null_;

           %commonn(result,action=GET);
           result=&equ;
           %commonn(result,action=PUT);
        run;quit;
      ');

  put result= 19.15;

cards4;
(13.1**3)**(1/3)
;;;;
run;quit;

