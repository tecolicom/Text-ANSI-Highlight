requires 'perl', 'v5.16';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'File::Temp';
};
