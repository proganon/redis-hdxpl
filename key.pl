:- setting(address_key, atom, env('ADDRESS_KEY', 'hdx:tcp'), '').

key_address(Key, Address) :-
    setting(address_key, AddressKey),
    redis(hdx, hget(AddressKey, Key), URL),
    url_address(URL, tcp, Address).
