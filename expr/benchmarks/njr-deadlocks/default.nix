{ utils, unzip, cpio }:
let 
  base = utils.fetchprop {
    url = "deadlocks.tar.gz";
    sha256 = "037mp1vicqcvf4ilig9facfq0djsd9dns0aa1d49v2k3hp2vkzz0";
  };
  bench = 
    { name
    , mainclass
    , subfolder
    }:
    utils.mkBenchmarkTemplate { 
      name = "njr-deadlock-${name}";
      inherit mainclass;
      tags = [ "deadlock" "njr" ];
      inputs =  [ { name = "default"; args = []; } ];
      build = java: {
        src = base;
        buildInputs = [ java.jdk ];
        phases = "unpackPhase patchPhase buildPhase installPhase";
        unpackPhase = ''
          tar zxf $src deadlocks/${subfolder}
          cd deadlocks/${subfolder}
        '';
        buildPhase = ''
          mkdir classes
          javac -encoding "UTF-8" -cp lib:classes @info/sources -d classes 
	  rm -r share
        '';
        installPhase = ''
          cp -r . $out
          mkdir -p $out/share/java
          jar cf $_/$name.jar -C classes .
          jar uf $out/share/java/$name.jar -C lib .
        '';
      };
    };
in
  rec { 
njr-deadlock-0 = bench { name = "0"; mainclass = "Deadlock.11.SimpleDeadLock"; subfolder = "urlbf284ef020_Beerkay_JavaMultiThreading_tgz-pJ8-Deadlock_11_SimpleDeadLockJ8"; };
njr-deadlock-1 = bench { name = "1"; mainclass = "Deadlock"; subfolder = "urlf4107b2f80_rickyclarkson_interviewquestions_tgz-pJ8-DeadlockJ8"; };
njr-deadlock-2 = bench { name = "2"; mainclass = "MyDeadlock"; subfolder = "url20eb6e8e1c_madhu006_JavaPrograms_tgz-pJ8-MyDeadlockJ8"; };
njr-deadlock-3 = bench { name = "3"; mainclass = "JavaThread.Deadlock"; subfolder = "url9e74b7967e_Buzov_JavaCore_tgz-pJ8-JavaThread_DeadlockJ8"; };
njr-deadlock-4 = bench { name = "4"; mainclass = "com.mohit.deadlock.DeadlockDemo"; subfolder = "urld6c652a068_mohit2_JavaQuestions_tgz-pJ8-com_mohit_deadlock_DeadlockDemoJ8"; };
njr-deadlock-5 = bench { name = "5"; mainclass = "MyDeadlock1"; subfolder = "url20eb6e8e1c_madhu006_JavaPrograms_tgz-pJ8-MyDeadlock1J8"; };
njr-deadlock-6 = bench { name = "6"; mainclass = "eu.javaspecialists.course.master.threads.solution241.PrinterClassTest"; subfolder = "url41e5e3b0c4_prasincs_JavaMasters_tgz-pJ8-eu_javaspecialists_course_master_threads_solution241_PrinterClassTestJ8"; };
njr-deadlock-7 = bench { name = "7"; mainclass = "threads.simulatedeadlock.DeadLockOreilly"; subfolder = "urlfb713cff44_techpanja_interviewproblemspublic_tgz-pJ8-threads_simulatedeadlock_DeadLockOreillyJ8"; };
njr-deadlock-8 = bench { name = "8"; mainclass = "com.mohit.threads.Deadlock"; subfolder = "urld6c652a068_mohit2_JavaQuestions_tgz-pJ8-com_mohit_threads_DeadlockJ8"; };
njr-deadlock-9 = bench { name = "9"; mainclass = "com.javawarriors.concurrency.Deadlock"; subfolder = "url292a8f5032_java_warriors_CrackTheJava_tgz-pJ8-com_javawarriors_concurrency_DeadlockJ8"; };
njr-deadlock-10 = bench { name = "10"; mainclass = "com.excelonline.core.threads.DeadLock"; subfolder = "url504456f3e4_jayramexcel_CoreJavaTraining_tgz-pJ8-com_excelonline_core_threads_DeadLockJ8"; };
njr-deadlock-11 = bench { name = "11"; mainclass = "com.oracle.sec4.liveness.Deadlock"; subfolder = "url8a68d340d2_jasonqu_akka_comparison_tgz-pJ8-com_oracle_sec4_liveness_DeadlockJ8"; };
njr-deadlock-12 = bench { name = "12"; mainclass = "com.nadia.crackcode.vira.Task1.Deadlocks"; subfolder = "urlf8d8432280_nadios_google_interview_tgz-pJ8-com_nadia_crackcode_vira_Task1_DeadlocksJ8"; };
njr-deadlock-13 = bench { name = "13"; mainclass = "eu.javaspecialists.course.master.threads.solution241.PrinterClassAutomaticDetectionTest"; subfolder = "url41e5e3b0c4_prasincs_JavaMasters_tgz-pJ8-eu_javaspecialists_course_master_threads_solution241_PrinterClassAutomaticDetectionTestJ8"; };
njr-deadlock-14 = bench { name = "14"; mainclass = "ch14.ex14.08.Friendly"; subfolder = "url10a89725a5_YasuharuFukuda_java_tgz-pJ8-ch14_ex14_08_FriendlyJ8"; };
njr-deadlock-15 = bench { name = "15"; mainclass = "legacy.concurrency.deadlock.DeadLock"; subfolder = "url8c0e6c1c4e_rbandara_algo_ds_tgz-pJ8-legacy_concurrency_deadlock_DeadLockJ8"; };
njr-deadlock-16 = bench { name = "16"; mainclass = "DeadLock"; subfolder = "urlcb67b5857e_Vikky_agrawalvikky_blogspot_tgz-pJ8-DeadLockJ8"; };
njr-deadlock-17 = bench { name = "17"; mainclass = "iven.juc.DeadLockTest"; subfolder = "url7eaffbd09a_doubledouble_me_tgz-pJ8-iven_juc_DeadLockTestJ8"; };
njr-deadlock-18 = bench { name = "18"; mainclass = "com.mohit.threads.DeadlockDemo"; subfolder = "urld6c652a068_mohit2_JavaQuestions_tgz-pJ8-com_mohit_threads_DeadlockDemoJ8"; };
njr-deadlock-19 = bench { name = "19"; mainclass = "com.aromero.thread.Deadlock1"; subfolder = "url10615400cc_rastarise_java7_tgz-pJ8-com_aromero_thread_Deadlock1J8"; };
njr-deadlock-20 = bench { name = "20"; mainclass = "concurrency.extended.SimpleNamePrinterHarness"; subfolder = "url95b566045f_definelicht_advancedjava_tgz-pJ8-concurrency_extended_SimpleNamePrinterHarnessJ8"; };
njr-deadlock-21 = bench { name = "21"; mainclass = "com.javawarriors.concurrency.DeadLockM"; subfolder = "url292a8f5032_java_warriors_CrackTheJava_tgz-pJ8-com_javawarriors_concurrency_DeadLockMJ8"; };
njr-deadlock-22 = bench { name = "22"; mainclass = "com.aromero.thread.Deadlock"; subfolder = "url10615400cc_rastarise_java7_tgz-pJ8-com_aromero_thread_DeadlockJ8"; };
njr-deadlock-23 = bench { name = "23"; mainclass = "com.practice.java.threads.DeadLockThread"; subfolder = "url0e293002db_mihirvjoshi_practice_java_tgz-pJ8-com_practice_java_threads_DeadLockThreadJ8"; };
njr-deadlock-24 = bench { name = "24"; mainclass = "WeakPoint.DeadLock"; subfolder = "url49d4612e49_hwlts_Note_tgz-pJ8-WeakPoint_DeadLockJ8"; };
njr-deadlock-25 = bench { name = "25"; mainclass = "hex.com.test19.synchronize.deadlock.DeadLock"; subfolder = "urla4cc83af93_huoex_java_sample_tgz-pJ8-hex_com_test19_synchronize_deadlock_DeadLockJ8"; };
njr-deadlock-26 = bench { name = "26"; mainclass = "com.mohit.deadlock.Deadlock"; subfolder = "urld6c652a068_mohit2_JavaQuestions_tgz-pJ8-com_mohit_deadlock_DeadlockJ8"; };
njr-deadlock-27 = bench { name = "27"; mainclass = "org.kyle.test.DeadLockTest"; subfolder = "urla088620892_kyleforever_Test_tgz-pJ8-org_kyle_test_DeadLockTestJ8"; };
njr-deadlock-28 = bench { name = "28"; mainclass = "threads.DeadlockDemo"; subfolder = "urld39d8a86c1_sivid_Javaworld_Java_101_tgz-pJ8-threads_DeadlockDemoJ8"; };
njr-deadlock-29 = bench { name = "29"; mainclass = "concurrency.DeadLock"; subfolder = "url686c805074_justutkarsh_java_interview_codes_tgz-pJ8-concurrency_DeadLockJ8"; };
njr-deadlock-30 = bench { name = "30"; mainclass = "DeadLock"; subfolder = "urleb1a636473_junyihuang_java_exercise_tgz-pJ8-DeadLockJ8"; };
all = [njr-deadlock-0 njr-deadlock-1 njr-deadlock-2 njr-deadlock-3 njr-deadlock-4 njr-deadlock-5 njr-deadlock-6 njr-deadlock-7 njr-deadlock-8 njr-deadlock-9 njr-deadlock-10 njr-deadlock-11 njr-deadlock-12 njr-deadlock-13 njr-deadlock-14 njr-deadlock-15 njr-deadlock-16 njr-deadlock-17 njr-deadlock-18 njr-deadlock-19 njr-deadlock-20 njr-deadlock-21 njr-deadlock-22 njr-deadlock-23 njr-deadlock-24 njr-deadlock-25 njr-deadlock-26 njr-deadlock-27 njr-deadlock-28 njr-deadlock-29 njr-deadlock-30];
  }
