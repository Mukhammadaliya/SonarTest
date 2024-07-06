type Lang_Code = 'en' | 'ru' | 'uz' | 'kk';
type Lang = { name: string; short_name: string; code: Lang_Code };
type T_text = { en: string; ru: string; uz: string; kk: string };
type T_dict = { [key: string]: T_text };
type Map = { [key: string]: string };
type Digit = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9;
type Phone_Uz = `+998${Digit & { length: 9 }}`;
type Company = { code: string; name: string };
type Otp_Code = `${Digit & { length: 6 }}`;
type Yes_No = 'Y' | 'N';

export {
  Lang_Code,
  Lang,
  T_text,
  T_dict,
  Map,
  Digit,
  Phone_Uz,
  Company,
  Otp_Code,
  Yes_No,
};
