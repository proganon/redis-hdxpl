url_address(URL, Protocol, Host:Port) :-
    parse_url(URL, Attributes),
    memberchk(protocol(Protocol), Attributes),
    memberchk(host(Host), Attributes),
    memberchk(port(Port), Attributes).
