pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftEjm is ERC721Enumerable, Ownable {
    string public baseURI;
    mapping(uint256 => string) private _hashIPFS;
    uint256[] codigos;
    uint256[] codigotitulos;
    uint256[] dnialumnos;
    //address[] alumanosmatriculados;
    mapping (uint256 => Asignatura) public asignaturas;
    mapping (uint256 => Titulo) public titulos;
    mapping(uint256=> Alumno)public asigalumnos;


    struct Asignatura{
        string nombre;
        uint256 codigo;
        uint32 creditos;
        address[] alumnos;
        uint256[] DNI;
        uint256[] trabajosrequeridos;
    }
    struct Titulo{
        string nombre;
        uint256 codigotitulo;
        uint256[] requeridos;
    }
    struct Alumno{
        uint256 identificadoralumno;
        uint256[] aprobadas;
        uint256[] trabajohecho;

    }
    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
        baseURI = "https://ipfs.io/ipfs/";
    }
    
    function addAsignatura(string memory _nombre, uint256 _co,uint32 _creditos)public onlyOwner{
        codigos.push(_co);
        asignaturas[_co].nombre = _nombre;
        asignaturas[_co].codigo = _co;
        asignaturas[_co].creditos = _creditos; 
    }
    function matricularalumno(uint256 _asig, address _alumno, uint256 _DNI)public onlyOwner{
        asignaturas[_asig].alumnos.push(_alumno);
        asignaturas[_asig].DNI.push(_DNI) ;
    }
    function addtrabajo(uint256 _asig, uint256 _numtrabajo) public onlyOwner{
    asignaturas[_asig].trabajosrequeridos.push(_numtrabajo);
    }
    function getAsignatura(uint256 _co) external view returns(uint256 codigo,uint32 creditos, address[] memory alumnos){
        codigo = asignaturas[_co].codigo;
        creditos = asignaturas[_co].creditos;
        alumnos = asignaturas[_co].alumnos;
    }   
    function createTitulo(string memory _nombre, uint256 _cot, uint256[] memory _identificadores) public  onlyOwner{
        codigotitulos.push(_cot);
        titulos[_cot].nombre = _nombre;
        titulos[_cot].codigotitulo = _cot;
        titulos[_cot].requeridos = _identificadores;
    }
    function getTitulo(uint256 _cot) external view returns(uint256 codigotitulo, uint256[] memory requeridos){
        codigotitulo = titulos[_cot].codigotitulo;
        requeridos = titulos[_cot].requeridos;

    }
    function addalumno(uint256 _DNI)public onlyOwner{
        dnialumnos.push(_DNI);
        asigalumnos[_DNI].identificadoralumno=_DNI ;
    }
    function mintTrabajo(address _to, string[] memory _hashes, uint256 _as, uint256 _numtrabajo ) public onlyOwner{
         address[] memory matriculados = asignaturas[_as].alumnos;
        uint8 matriculado = 0;
        uint256 indexa = 0;
        for( uint256 a = 0; a< matriculados.length;a++){
            if(_to == matriculados[a]){
                matriculado++;
                indexa=a;
            } 
        }
        require (matriculado == 1, "La direccion no corresponde con ningun alumno matriculado");
         uint256 dni= asignaturas[_as].DNI[indexa];
         uint256 dnif=dni*10000000000;
         uint256 idtoken = dnif+_as*100+_numtrabajo; 
         asigalumnos[dni].trabajohecho.push(_numtrabajo);
          for (uint256 i = 0; i < _hashes.length; i++) {
            _safeMint(_to, idtoken + i);
            _hashIPFS[idtoken + i] = _hashes[i];
        }
        

        
    }
    function mintAsignatura(address _to, string[] memory _hashes, uint256[] memory _nota, uint256[] memory _porcentaje, uint256 _as) public onlyOwner {
        //uint256 ident = _ident;
        //uint32 existe= 0;
        uint256 code= asignaturas[_as].codigo;
        uint256 media = 0;
      /*  for (uint256 z = 0; z < codigos.length; z++) {
          if( codigos[z]==code){
              existe++;
          }
        }
        require(existe==1,"Esta asignatura no existe");
        */
        address[] memory matriculados = asignaturas[_as].alumnos;
       // uint256[] dnimatriculados = _as.DNI;
        uint8 matriculado = 0;
        uint256 indexa = 0;
        for( uint256 a = 0; a< matriculados.length;a++){
            if(_to == matriculados[a]){
                matriculado++;
                indexa=a;
            } 
        }
        uint256 dni= asignaturas[_as].DNI[indexa];
        require (matriculado == 1, "La direccion no corresponde con ningun alumno matriculado");
        uint256[] memory _code = asignaturas[_as].trabajosrequeridos;
        matriculado = matriculado -1;
        uint256[] memory trabaprobalumno=asigalumnos[dni].trabajohecho ;
       for (uint256 k = 0; k < _code.length; k++){
           for(uint256 j = 0; j< trabaprobalumno.length;j++){
           if(trabaprobalumno[j]==_code[k]){
               matriculado++;
           }       
       }
       }    
         require(
            matriculado==_code.length,
            "No ha realizado todos los trabajos"
        );
        

        for (uint256 j = 0; j < _nota.length; j++) {
            media=media+_nota[j]*_porcentaje[j]/100;
        } 
         //uint256 media = media(_nota,_porcentaje); 
        require(media>5, "Nota insuficiente");
       
    
        //calcular tokenID
       
        uint256 idtoken = dni*100000000+code;
      
        asigalumnos[dni].aprobadas.push(code);
        
        for (uint256 i = 0; i < _hashes.length; i++) {
            _safeMint(_to, idtoken + i);
            _hashIPFS[idtoken + i] = _hashes[i];
        }
    }
   

    function mintTitulo(address _to, string[] memory _hashes, uint256 _tit, uint256 _DNI) public onlyOwner {
        uint256[] memory _code = titulos[_tit].requeridos;
        uint32 contador = 0;
        uint256[] memory asigaprobalumno=asigalumnos[_DNI].aprobadas ;
       for (uint256 k = 0; k < _code.length; k++){
           for(uint256 j = 0; j< asigaprobalumno.length;j++){
           if(asigaprobalumno[j]==_code[k]){
               contador++;
           }       
       }
       }    
         require(
            contador==_code.length,
            "No ha aprobado todas las asignaturas"
        );
        
        
       uint256 tokentit=_DNI*100+_tit;
        for (uint256 i = 0; i < _hashes.length; i++) {
            _safeMint(_to, tokentit + i);
            _hashIPFS[tokentit + i] = _hashes[i];
        }
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            (bytes(currentBaseURI).length > 0 &&
                bytes(_hashIPFS[tokenId]).length > 0)
                ? string(abi.encodePacked(currentBaseURI, _hashIPFS[tokenId]))
                : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
}