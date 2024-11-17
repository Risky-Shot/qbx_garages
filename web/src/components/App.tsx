import React, { useState } from "react";
import "./App.css";
import { debugData } from "../utils/debugData";
import { fetchNui } from "../utils/fetchNui";
import { useNuiEvent } from "../hooks/useNuiEvent";

debugData([
  {
    action: "setVisible",
    data: true,
  },
]);
interface VehicleDetail {
  label: string;
  value: string | number;
}
interface CarDetails {
  id: number;
  logo: string;
  manufacturerName: string;
  carName: string;
  vehicleDetails: VehicleDetail[];
  garage: string;
  numberPlate: string;
  depotPrice?: number;
}
interface Player {
  id: string;
  name: string;
  owner: boolean;
}
interface GarageData {
  garageId: string;
  garageName: string;
  garageType: string;
  accessPoint: string;
}
// const carData: CarDetails[] = [
//   {
//     id: 1,
//     logo: (
//       <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24">
//         <path fill="currentColor" d="M12 19.875q-.425 0-.825-.187t-.7-.538L2.825 10q-.225-.275-.337-.6t-.113-.675q0-.225.038-.462t.162-.438L4.45 4.1q.275-.5.738-.8T6.225 3h11.55q.575 0 1.038.3t.737.8l1.875 3.725q.125.2.163.437t.037.463q0 .35-.112.675t-.338.6l-7.65 9.15q-.3.35-.7.538t-.825.187M9.625 8h4.75l-1.5-3h-1.75zM11 16.675V10H5.45zm2 0L18.55 10H13zM16.6 8h2.65l-1.5-3H15.1zM4.75 8H7.4l1.5-3H6.25z"/>
//       </svg>
//     ),
//     manufacturerName: "BENEFACTOR",
//     carName: "BIG ASS CAR NAME",
//     vehicleDetails: [
//       { label: "Vehicle Health", value: "98%" },
//       { label: "Fuel", value: "98%" },
//       // Add other vehicle details here if needed
//     ],
//     garage: "Airport Garage",
//     numberPlate: "dwadawda",
//   },
//   {
//     id: 2,
//     logo: (
//       <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24">
//         <path fill="currentColor" d="M12 19.875q-.425 0-.825-.187t-.7-.538L2.825 10q-.225-.275-.337-.6t-.113-.675q0-.225.038-.462t.162-.438L4.45 4.1q.275-.5.738-.8T6.225 3h11.55q.575 0 1.038.3t.737.8l1.875 3.725q.125.2.163.437t.037.463q0 .35-.112.675t-.338.6l-7.65 9.15q-.3.35-.7.538t-.825.187M9.625 8h4.75l-1.5-3h-1.75zM11 16.675V10H5.45zm2 0L18.55 10H13zM16.6 8h2.65l-1.5-3H15.1zM4.75 8H7.4l1.5-3H6.25z"/>
//       </svg>
//     ),
//     manufacturerName: "BENEFACTOR",
//     carName: "BIG ASS CAR NAME",
//     vehicleDetails: [
//       { label: "Vehicle Health", value: "98%" },
//       { label: "Fuel", value: "98%" },
//       // Add other vehicle details here if needed
//     ],
//     garage: "Airport Garage",
//     numberPlate: "dwadawda",
//   },
//   {
//     id: 3,
//     logo: (
//       <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24">
//         <path fill="currentColor" d="M12 19.875q-.425 0-.825-.187t-.7-.538L2.825 10q-.225-.275-.337-.6t-.113-.675q0-.225.038-.462t.162-.438L4.45 4.1q.275-.5.738-.8T6.225 3h11.55q.575 0 1.038.3t.737.8l1.875 3.725q.125.2.163.437t.037.463q0 .35-.112.675t-.338.6l-7.65 9.15q-.3.35-.7.538t-.825.187M9.625 8h4.75l-1.5-3h-1.75zM11 16.675V10H5.45zm2 0L18.55 10H13zM16.6 8h2.65l-1.5-3H15.1zM4.75 8H7.4l1.5-3H6.25z"/>
//       </svg>
//     ),
//     manufacturerName: "BENEFACTOR",
//     carName: "BIG ASS CAR NAME",
//     vehicleDetails: [
//       { label: "Vehicle Health", value: "98%" },
//       { label: "Fuel", value: "98%" },
//       // Add other vehicle details here if needed
//     ],
//     garage: "Airport Garage",
//     numberPlate: "dwadawda",
//   },
//   {
//     id: 4,
//     logo: (
//       <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24">
//         <path fill="currentColor" d="M12 19.875q-.425 0-.825-.187t-.7-.538L2.825 10q-.225-.275-.337-.6t-.113-.675q0-.225.038-.462t.162-.438L4.45 4.1q.275-.5.738-.8T6.225 3h11.55q.575 0 1.038.3t.737.8l1.875 3.725q.125.2.163.437t.037.463q0 .35-.112.675t-.338.6l-7.65 9.15q-.3.35-.7.538t-.825.187M9.625 8h4.75l-1.5-3h-1.75zM11 16.675V10H5.45zm2 0L18.55 10H13zM16.6 8h2.65l-1.5-3H15.1zM4.75 8H7.4l1.5-3H6.25z"/>
//       </svg>
//     ),
//     manufacturerName: "BENEFACTOR",
//     carName: "BIG ASS CAR NAME",
//     vehicleDetails: [
//       { label: "Vehicle Health", value: "98%" },
//       { label: "Fuel", value: "98%" },
//       // Add other vehicle details here if needed
//     ],
//     garage: "Airport Garage",
//     numberPlate: "dwadawda",
//   },
//   {
//     id: 5,
//     logo: (
//       <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24">
//         <path fill="currentColor" d="M12 19.875q-.425 0-.825-.187t-.7-.538L2.825 10q-.225-.275-.337-.6t-.113-.675q0-.225.038-.462t.162-.438L4.45 4.1q.275-.5.738-.8T6.225 3h11.55q.575 0 1.038.3t.737.8l1.875 3.725q.125.2.163.437t.037.463q0 .35-.112.675t-.338.6l-7.65 9.15q-.3.35-.7.538t-.825.187M9.625 8h4.75l-1.5-3h-1.75zM11 16.675V10H5.45zm2 0L18.55 10H13zM16.6 8h2.65l-1.5-3H15.1zM4.75 8H7.4l1.5-3H6.25z"/>
//       </svg>
//     ),
//     manufacturerName: "BENEFACTOR",
//     carName: "BIG ASS CAR NAME",
//     vehicleDetails: [
//       { label: "Vehicle Health", value: "98%" },
//       { label: "Fuel", value: "98%" },
//       // Add other vehicle details here if needed
//     ],
//     garage: "Airport Garage",
//     numberPlate: "dwadawda",
//   },
//   {
//     id: 6,
//     logo: (
//       <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24">
//         <path fill="currentColor" d="M12 19.875q-.425 0-.825-.187t-.7-.538L2.825 10q-.225-.275-.337-.6t-.113-.675q0-.225.038-.462t.162-.438L4.45 4.1q.275-.5.738-.8T6.225 3h11.55q.575 0 1.038.3t.737.8l1.875 3.725q.125.2.163.437t.037.463q0 .35-.112.675t-.338.6l-7.65 9.15q-.3.35-.7.538t-.825.187M9.625 8h4.75l-1.5-3h-1.75zM11 16.675V10H5.45zm2 0L18.55 10H13zM16.6 8h2.65l-1.5-3H15.1zM4.75 8H7.4l1.5-3H6.25z"/>
//       </svg>
//     ),
//     manufacturerName: "BENEFACTOR",
//     carName: "BIG ASS CAR NAME",
//     vehicleDetails: [
//       { label: "Vehicle Health", value: "98%" },
//       { label: "Fuel", value: "98%" },
//       // Add other vehicle details here if needed
//     ],
//     garage: "Airport Garage",
//     numberPlate: "dwadawda",
//   },
//   // Add more car objects as needed
// ];
const App: React.FC = () => {
  const [selectedCarId, setSelectedCarId] = useState<number | null>(null);
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [garageData, setGarageData] = useState<GarageData>({
    garageId: '',
    garageName: '',     // Initialize with default values or pass actual values
    garageType: '',
    accessPoint: '',
  });
  const [vehicleData, setVehicleData] = useState<CarDetails[]>([]);

  const handleSelectCar = (id: number) => {
    setSelectedCarId(id);
  };
  const handleSearchChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setSearchQuery(event.target.value);
  };

  const filteredCarData = vehicleData.filter(car => {
    const query = searchQuery.toLowerCase();
    return car.carName.toLowerCase().includes(query) || car.numberPlate.toLowerCase().includes(query);
  });
  const [selectedLogo, setSelectedLogo] = useState("logo1");
  const handleClick = (logo: string) => {
    setSelectedLogo(logo);
  };

  const [players, setPlayers] = useState<Player[]>([]);
  const [citizenIdInput, setCitizenIdInput] = useState<string>("");
  const [searchPlayerName, setSearchPlayerName] = useState<string>("");
  const [isOwner, setIsOwner] = useState(false)
  const addPlayerByCitizenId = () => {
    const existingPlayer = players.find((player) => player.id === citizenIdInput);
    if (existingPlayer) {
      console.log("Player is already added");
    } else {
      fetchNui('qbx_garages:addToParking', {
        garageName: garageData.garageId, 
        accessPoint: garageData.accessPoint, 
        citizenid: citizenIdInput
      })
      .then(() => {})
      .catch((e) => {
        console.error("Error occurred:", e);
      });
      //setPlayers((prevPlayers) => [...prevPlayers, playerData]);
      setCitizenIdInput(""); 
    }
  };
  const removePlayer = (id: string) => {
    const existingPlayer = players.find((player) => player.id === id);
    if (existingPlayer) {
      fetchNui('qbx_garages:removeFromParking', {
        garageName: garageData.garageId, 
        accessPoint: garageData.accessPoint, 
        citizenid: id
      }).then(()=> {
        fetchNui('garages:closeUI', {})
      })
    } else {
      console.log('player doesn`t exist!');
    }
  };
  const filteredPlayers = players.filter((player) =>
    player.name.toLowerCase().includes(searchPlayerName.toLowerCase())
  );

  useNuiEvent('Garages:Get:InitialData', (data: any) => {
    console.log(JSON.stringify(data))
    setGarageData({
      garageId: data.garageData.garageId,
      garageName: data.garageData.garageName,
      garageType: data.garageData.garageType || 'GARAGE',
      accessPoint: data.garageData.accessPoint,
    });
    setVehicleData(() => [
      ...data.vehiclesData.map((vehicle: any) => ({
        id: vehicle.id,
        logo: vehicle.manufacturerName,
        manufacturerName: vehicle.manufacturerName,
        carName: vehicle.carName,
        vehicleDetails: Object.keys(vehicle.vehicleDetails).map((key) => {
          return {
            label: vehicle.vehicleDetails[key].label,
            value: vehicle.vehicleDetails[key].value,
          }
        }),
        garage: vehicle.garage,
        numberPlate: vehicle.numberPlate,
        depotPrice: vehicle.depotPrice || 0,
      })),
    ]);
    if (data.garageData?.garageType == 'parking') {
      console.log('Parking Garage. Setting Owner and Players');
      setIsOwner(data.isOwner);
      setPlayers(() => [
        ...data.playersData.map((player: any) => ({
          id: player.id,
          name: player.name,
          owner: player.isOwner
        })),
      ]);
    }
  });

  useNuiEvent('Garages:refreshPlayers', (data: any) => {
    setPlayers(() => [
        ...data.map((player: any) => ({
          id: player.id,
          name: player.name,
          owner: player.isOwner
        })),
      ]);
  });

  return (
    <>
      <div className="bg-container"></div>
      <div className="left-container">
        <div className="left-container-heading-container">
          <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 15 15"><path fill="currentColor" d="M7.21.093a.5.5 0 0 1 .58 0l7 5A.5.5 0 0 1 15 5.5v9a.5.5 0 0 1-.5.5H13V7H2v8H.5a.5.5 0 0 1-.5-.5v-9a.5.5 0 0 1 .21-.407z"/><path fill="currentColor" fill-rule="evenodd" d="M3 15h9v-4H3zm6-2H6v-1h3z" clip-rule="evenodd"/><path fill="currentColor" d="M12 10V8H3v2z"/></svg>
          <span className="left-container-heading">{garageData.garageName}</span>
        </div>
        <div className="left-container-subheading">{garageData.garageType} | {garageData.accessPoint}</div>
        {selectedLogo === 'logo1' ? (<>
          <div className="left-container-searchBar">
            <input
              type="text"
              placeholder="Plate Number or Car Name"
              value={searchQuery}
              onChange={handleSearchChange}
            />
            <span className="search-icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24">
                <path fill="currentColor" d="m19.6 21l-6.3-6.3q-.75.6-1.725.95T9.5 16q-2.725 0-4.612-1.888T3 9.5t1.888-4.612T9.5 3t4.613 1.888T16 9.5q0 1.1-.35 2.075T14.7 13.3l6.3 6.3zM9.5 14q1.875 0 3.188-1.312T14 9.5t-1.312-3.187T9.5 5T6.313 6.313T5 9.5t1.313 3.188T9.5 14"/>
              </svg>
            </span>
          </div>
          <div className="left-container-card-container">
            {filteredCarData.map((car: any) => (
              <div
                key={car.id}
                className={`left-container-card ${selectedCarId === car.id ? "selected" : ""}`}
                onClick={() => handleSelectCar(car.id)}
              >
                <div className="left-container-card-logo">{car.logo}</div>
                <div className="left-container-card-carDetails">
                  <div className="left-container-card-manufacturerName">{car.manufacturerName}</div>
                  <div className="left-container-card-CarName">{car.carName}</div>
                  <div className="left-container-card-VehicleDetails">
                    {car.vehicleDetails.map((detail:any, index:number) => (
                      <div key={index}>
                        <span className="left-container-card-key">{detail.label} - </span>
                        <span className="left-container-card-value">{detail.value}</span>
                      </div>
                    ))}
                  </div>
                  <div className="left-container-card-Garage">
                    <span className="left-container-card-key">Garage - </span>
                    <span className="left-container-card-value">{car.garage}</span>
                  </div>
                </div>
                <div className="left-container-card-numberPlate">
                  <div className="left-container-card-numberPlate-Image">
                    <div>{car.numberPlate}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
          <div className="left-container-bottomButton" onClick={() => {
            fetchNui('qbx_garages:DriveVehicle', {
              garageName : garageData.garageId,
              garageType :garageData.garageType,
              accessPoint : garageData.accessPoint,
              vehicleId : selectedCarId,
            })
          }}>Drive Now</div>
        </>) : selectedLogo === 'logo2' && (<>
          <div className="left-container-management">
          {isOwner === true  && (
            <div className="left-container-add-player">
              <input
                type="text"
                placeholder="Type Citizen ID"
                value={citizenIdInput}
                onChange={(e) => setCitizenIdInput(e.target.value)}
              />
              <span className="search-icon" onClick={addPlayerByCitizenId}>
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24"><path fill="currentColor" d="M12 21q-.425 0-.712-.288T11 20v-7H4q-.425 0-.712-.288T3 12t.288-.712T4 11h7V4q0-.425.288-.712T12 3t.713.288T13 4v7h7q.425 0 .713.288T21 12t-.288.713T20 13h-7v7q0 .425-.288.713T12 21"/></svg>
              </span>
            </div>
          )}
            <div className="left-container-search-player">
              <input
                type="text"
                placeholder="Search Player Name"
                value={searchPlayerName}
                onChange={(e) => setSearchPlayerName(e.target.value)}
              />
              <span className="search-icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24">
                  <path fill="currentColor" d="m19.6 21l-6.3-6.3q-.75.6-1.725.95T9.5 16q-2.725 0-4.612-1.888T3 9.5t1.888-4.612T9.5 3t4.613 1.888T16 9.5q0 1.1-.35 2.075T14.7 13.3l6.3 6.3zM9.5 14q1.875 0 3.188-1.312T14 9.5t-1.312-3.187T9.5 5T6.313 6.313T5 9.5t1.313 3.188T9.5 14"/>
                </svg>
              </span>
            </div>
          </div>
          <div className="left-container-card-container">
            {filteredPlayers.map((player) => (
              <div key={player.id} className="left-container-management-card">
                <div className="left-container-management-sub-card">
                  <div className="left-container-management-card-icon">
                    <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24">
                      <path
                        fill="currentColor"
                        d="M6.196 17.485q1.275-.918 2.706-1.451Q10.332 15.5 12 15.5t3.098.534t2.706 1.45q.99-1.025 1.593-2.42Q20 13.667 20 12q0-3.325-2.337-5.663T12 4T6.337 6.338T4 12q0 1.667.603 3.064q.603 1.396 1.593 2.42M12 12.5q-1.263 0-2.132-.868T9 9.5t.868-2.132T12 6.5t2.132.868T15 9.5t-.868 2.132T12 12.5m0 8.5q-1.883 0-3.525-.701t-2.858-1.916t-1.916-2.858T3 12t.701-3.525t1.916-2.858q1.216-1.215 2.858-1.916T12 3t3.525.701t2.858 1.916t1.916 2.858T21 12t-.701 3.525t-1.916 2.858q-1.216 1.215-2.858 1.916T12 21"
                      />
                    </svg>
                  </div>
                  <div className="left-container-management-card-name">
                    {player.name} | {player.id}
                  </div>
                </div>
                {(isOwner === true && player.owner === false) && (
                  <div className="left-container-management-card-buttton" onClick={() => removePlayer(player.id)}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="36" height="36" viewBox="0 0 24 24">
                      <path fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="2" d="M20 20L4 4m16 0L4 20" />
                    </svg>
                  </div>
                )}
              </div>
            ))}
            <></>
          </div>
        </>)}
      </div>


      <div className="right-container">
        <div
          className={`logo-1 ${selectedLogo === 'logo1' ? 'selected' : ''}`}
          onClick={() => handleClick('logo1')}
        >
        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 36 36">
          <path fill="currentColor" d="M33 19a1 1 0 0 1-.71-.29L18 4.41L3.71 18.71A1 1 0 0 1 2.3 17.3l15-15a1 1 0 0 1 1.41 0l15 15A1 1 0 0 1 33 19" className="clr-i-solid clr-i-solid-path-1"/>
          <path fill="currentColor" d="M18 7.79L6 19.83V32a2 2 0 0 0 2 2h7V24h6v10h7a2 2 0 0 0 2-2V19.76Z" className="clr-i-solid clr-i-solid-path-2"/>
          <path fill="none" d="M0 0h36v36H0z"/>
        </svg>
        </div>
        {garageData.garageType === 'parking'  && (
          <div
            className={`logo-2 ${selectedLogo === 'logo2' ? 'selected' : ''}`}
            onClick={() => handleClick('logo2')}
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="52" height="52" viewBox="0 0 16 16">
              <path fill="currentColor" d="M3 3a2 2 0 1 1 4 0a2 2 0 0 1-4 0m6.779 1.584l.042.032a2 2 0 1 0-.042-.032M6.268 6A2 2 0 1 1 9.73 7.998A2 2 0 0 1 6.268 6M2.5 6h2.67a3.01 3.01 0 0 0 .594 3H5.5a2.5 2.5 0 0 0-2.355 1.658a3.7 3.7 0 0 1-.933-.543C1.46 9.51 1 8.616 1 7.5A1.5 1.5 0 0 1 2.5 6m8 3c1.085 0 2.009.691 2.355 1.658c.34-.139.654-.32.933-.543C14.54 9.51 15 8.616 15 7.5A1.5 1.5 0 0 0 13.5 6h-2.67c.11.313.17.65.17 1a3 3 0 0 1-.764 2zm1.387 1.928c.073.176.113.37.113.572c0 1.116-.459 2.01-1.212 2.615C10.047 14.71 9.053 15 8 15s-2.047-.29-2.788-.885C4.46 13.51 4 12.616 4 11.5A1.496 1.496 0 0 1 5.5 10h5a1.5 1.5 0 0 1 1.387.928"/>
            </svg>
          </div>
        )}
      </div>
    </>
  );
};

export default App;
