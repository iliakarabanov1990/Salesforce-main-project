public with sharing class Utilities {

    public static String formatMoney(String s) {
        s = '$' + s;
        if (!s.contains('.')) {
            s = s + '.00';
        } else {
          Integer dPos = s.indexOf('.');
          if (s.length() - dPos < 3) { s = s + '0'; }   
        }
        return s; 
    }
}