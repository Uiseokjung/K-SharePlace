import React from 'react';
import Sidebar from './sideBar';
import Banner from './banner';

const Notification = () => {
    return (
        <div className="main-container">
          <Banner />
          <div className="sidebar-and-content">
            <Sidebar />
            <div className="main-content">
            </div>
          </div>
        </div>
      );
    }

export default Notification;