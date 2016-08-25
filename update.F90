!***********************************************************************
!       SUBROUTINE UPDATE PERFORMS COMMUNICATIONS BETWEEN PROCESSES
!       TO UPDATE OVERLAPPING VALUES
!                     
!                    
!                     
!                   O.R           O.R
!                  +---+---------+---+ <--IBEGY
! OVERLAP REGION   |   |         |   |
!                  +---+---------+---+ <--IRBEGY
!                  |   |         |   |
!                  |   |         |   |
!                  |   |         |   |
!                  +---+---------+---+ <--IRENDY
! OVERLAP REGION   |   |         |   |
!                  +---+---------+---+ <--IENDY
!                  ^   ^         ^   ^
!              IBEGX IRBEGX   IRENDX IENDX
!
!***********************************************************************

SUBROUTINE UPDATE
#if OVERLAP_METHOD==1
!
  USE PARALLEL
  USE MESH
  USE VARIABLES
  USE UPDATE_MOD
!
  IMPLICIT NONE
! 
  INTEGER :: I,J,K,L,IBUF,STAT,N1,N2,DIM,LEN,log
  CHARACTER*(200) ::STRING
  CHARACTER*(4) logname
  INTEGER    STATS(MPI_STATUS_SIZE,6)
!
  !S_3D(1:NX,1:NY,1:NZ, 1:NVAR)=MYRANK*100
  IBUF=1
  !WEST
  IF(SIZE_W .NE. 0) THEN
     DO L=1,NVAR  
        DO K=IRBEGZ,IRENDZ
           DO J=IRBEGY,IRENDY
              DO I=IRBEGX,IRBEGX+OVERX-1
                 SBUF(IBUF) = S_3D(I,J,K,L)
                 IBUF=IBUF+1
              END DO
           END DO
        END DO
     END DO
  END IF
  !EAST
  IF(SIZE_E .NE. 0) THEN
     DO L=1,NVAR  
        DO K=IRBEGZ,IRENDZ
           DO J=IRBEGY,IRENDY
              DO I=IRENDX-OVERX+1,IRENDX
                 SBUF(IBUF) = S_3D(I,J,K,L)
                 IBUF=IBUF+1
              END DO
           END DO
        END DO
     END DO
  END IF
  !NORTH
  IF(SIZE_N .NE. 0) THEN
     DO L=1,NVAR  
        DO K=IRBEGZ,IRENDZ
           DO J=IRBEGY,IRBEGY+OVERY-1
              DO I=IRBEGX,IRENDX
                 SBUF(IBUF) = S_3D(I,J,K,L)
                 IBUF=IBUF+1
              END DO
           END DO
        END DO
     END DO
  END IF
  !SOUTH
  IF(SIZE_S .NE. 0) THEN
     DO L=1,NVAR  
        DO K=IRBEGZ,IRENDZ
           DO J=IRENDY-OVERY+1,IRENDY
              DO I=IRBEGX,IRENDX
                 SBUF(IBUF) = S_3D(I,J,K,L)
                 IBUF=IBUF+1
              END DO
           END DO
        END DO
     END DO
  END IF
  !FRONT
  IF(SIZE_F .NE. 0) THEN
     DO L=1,NVAR  
        DO K=IRBEGZ,IRBEGZ+OVERZ-1
           DO J=IRBEGY,IRENDY
              DO I=IRBEGX,IRENDX
                 SBUF(IBUF) = S_3D(I,J,K,L)
                 IBUF=IBUF+1
              END DO
           END DO
        END DO
     END DO
  END IF
  !BACK
  IF(SIZE_B .NE. 0) THEN
     DO L=1,NVAR  
        DO K=IRENDZ-OVERZ+1,IRENDZ
           DO J=IRBEGY,IRENDY
              DO I=IRBEGX,IRENDX
                 SBUF(IBUF) = S_3D(I,J,K,L)
                 IBUF=IBUF+1
              END DO
           END DO
        END DO
     END DO
  END IF
 !
  !WRITE(*,*)MYRANK,"End packing, ibuf=",IBUF
!  
  !write(*,100)MYRANK,OFF_W,OFF_E,OFF_N,OFF_S,OFF_F,OFF_B,BUF_SIZE
  100 Format('Offsets ',1I3,': ',7I8)
!
  T1=MPI_Wtime()
!
#if COMM_METHOD == 1
  CALL MPI_neighbor_alltoallv(sbuf, scounts, sdispls, MPI_DOUBLE_PRECISION, rbuf, scounts, sdispls, MPI_DOUBLE_PRECISION, COMM_GRID, IERR)
#elif COMM_METHOD == 2
  I=1
  DO DIM=0,NDIM-1
     CALL MPI_CART_SHIFT(COMM_GRID,DIM,1,N1, N2, IERR)
     !
     CALL MPI_Isend(sbuf(sdispls(I)+1),scounts(I), MPI_DOUBLE_PRECISION, N1, 0, COMM_GRID, SREQS(I), IERR)
     CALL MPI_Irecv(rbuf(sdispls(I)+1),scounts(I), MPI_DOUBLE_PRECISION, N1, 1, COMM_GRID, RREQS(I), IERR)
     I=I+1
     CALL MPI_Isend(sbuf(sdispls(I)+1),scounts(I), MPI_DOUBLE_PRECISION, N2, 1, COMM_GRID, SREQS(I), IERR)
     CALL MPI_Irecv(rbuf(sdispls(I)+1),scounts(I), MPI_DOUBLE_PRECISION, N2, 0, COMM_GRID, RREQS(I), IERR)
     I=I+1
  END DO
  !
  CALL MPI_WAITALL(NDIM*2, RREQS, MPI_STATUSES_IGNORE, IERR)
  CALL MPI_WAITALL(NDIM*2, SREQS, MPI_STATUSES_IGNORE, IERR)
#else
  WRITE(*,*)"No communication method defined..."
#endif
!
  T2=MPI_Wtime()
  TOTAL=TOTAL+T2-T1
!
!     UNPACK RECEIVED DATA
!
  !TODO Supprimer les if ?
  IBUF=1
  !WEST
  IF(SIZE_W .NE. 0) THEN
     DO L=1,NVAR  
        DO K=IRBEGZ,IRENDZ
           DO J=IRBEGY,IRENDY
              DO I=1,IRBEGX-1
                 S_3D(I,J,K,L)=RBUF(IBUF) 
                 IBUF=IBUF+1
              END DO
           END DO
        END DO
     END DO
  END IF
  !EAST
  IF(SIZE_E .NE. 0) THEN
     DO L=1,NVAR  
        DO K=IRBEGZ,IRENDZ
           DO J=IRBEGY,IRENDY
              DO I=IRENDX+1,NX
                 S_3D(I,J,K,L)=RBUF(IBUF)
                 IBUF=IBUF+1
              END DO
           END DO
        END DO
     END DO
  END IF
  !NORTH
  IF(SIZE_N .NE. 0) THEN
     DO L=1,NVAR  
        DO K=IRBEGZ,IRENDZ
           DO J=1,IRBEGY-1
              DO I=IRBEGX,IRENDX
                 S_3D(I,J,K,L)=RBUF(IBUF)
                 IBUF=IBUF+1
              END DO
           END DO
        END DO
     END DO
  END IF
  !SOUTH
  IF(SIZE_S .NE. 0) THEN
     DO L=1,NVAR  
        DO K=IRBEGZ,IRENDZ
           DO J=IRENDY+1,NY
              DO I=IRBEGX,IRENDX
                 S_3D(I,J,K,L)=RBUF(IBUF)
                 IBUF=IBUF+1
              END DO
           END DO
        END DO
     END DO
  END IF
  !FRONT
  IF(SIZE_F .NE. 0) THEN
     DO L=1,NVAR  
        DO K=1,IRBEGZ-1
           DO J=IRBEGY,IRENDY
              DO I=IRBEGX,IRENDX
                 S_3D(I,J,K,L)=RBUF(IBUF)
                 IBUF=IBUF+1
              END DO
           END DO
        END DO
     END DO
  END IF
  !BACK
  IF(SIZE_B .NE. 0) THEN
     DO L=1,NVAR  
        DO K=IRENDZ+1,NZ
           DO J=IRBEGY,IRENDY
              DO I=IRBEGX,IRENDX
                 S_3D(I,J,K,L)=RBUF(IBUF)
                 IBUF=IBUF+1
              END DO
           END DO
        END DO
     END DO
  END IF
  !WRITE(*,*)MYRANK,"End unpacking, ibuf=",IBUF
!
  !CALL SAVE_FIELDS(.TRUE.)
  !CALL SAVE_FIELDS(.FALSE.)
  
!
#endif !OVERLAP_METHOD
END SUBROUTINE UPDATE



SUBROUTINE INIT_UPDATE
!
  USE PARALLEL
  USE UPDATE_MOD
  USE MESH
  USE MAPPING
!
  IMPLICIT NONE
!
  INTEGER :: NXR,NYR,NZR,OFF_W,OFF_E,OFF_N,OFF_S,OFF_F,OFF_B,BUF_SIZE,NB_ELEMS
!
  TOTAL=0.D0
!
#if OVERLAP_METHOD==1
  NB_ELEMS=NVAR
#elif OVERLAP_METHOD==2
  NB_ELEMS=1
#endif
  !WRITE(*,*)IRENDX,IRBEGX,IRENDY,IRBEGY,IRBEGZ,IRENDZ,OVERX,OVERY,OVERZ
  NXR=IRENDX-IRBEGX+1
  NYR=IRENDY-IRBEGY+1
  NZR=IRENDZ-IRBEGZ+1
  !WRITE(*,*)NXR,NYR,NZR,NVAR
!

!
!     Compute sizes of buffers
!
  IF(PERIODIC_X .NE. 1) THEN
     IF(POS_X .EQ. 0) THEN
        SIZE_W=0
     ELSE 
        SIZE_W=OVERX*NYR*NZR*NB_ELEMS
     END IF
     IF(POS_X .EQ. NPROCX-1) THEN
        SIZE_E=0
     ELSE 
        SIZE_E=OVERX*NYR*NZR*NB_ELEMS
     END IF
  ELSE
     SIZE_W=OVERX*NYR*NZR*NB_ELEMS
     SIZE_E=OVERX*NYR*NZR*NB_ELEMS
  END IF
!
  IF(PERIODIC_Y .NE. 1) THEN
     IF(POS_Y .EQ. 0) THEN
        SIZE_N=0
     ELSE 
        SIZE_N=NXR*OVERY*NZR*NB_ELEMS
     END IF
     IF(POS_Y .EQ. NPROCY-1) THEN
        SIZE_S=0
     ELSE 
        SIZE_S=NXR*OVERY*NZR*NB_ELEMS
     END IF
  ELSE
     SIZE_N=NXR*OVERY*NZR*NB_ELEMS
     SIZE_S=NXR*OVERY*NZR*NB_ELEMS
  END IF
!
  IF(PERIODIC_Z .NE. 1) THEN
     IF(POS_Z .EQ. 0) THEN
        SIZE_F=0
     ELSE 
        SIZE_F=NXR*NYR*OVERZ*NB_ELEMS
     END IF
     IF(POS_Z .EQ. NPROCZ-1) THEN
        SIZE_B=0
     ELSE 
        SIZE_B=NXR*NYR*OVERZ*NB_ELEMS
     END IF
  ELSE
     SIZE_F=NXR*NYR*OVERZ*NB_ELEMS
     SIZE_B=NXR*NYR*OVERZ*NB_ELEMS
  END IF
!
  OFF_W=0
  OFF_E=OFF_W+SIZE_W
  OFF_N=OFF_E+SIZE_E
  OFF_S=OFF_N+SIZE_N
  OFF_F=OFF_S+SIZE_S
  OFF_B=OFF_F+SIZE_F
  BUF_SIZE=OFF_B+SIZE_B
!
#if OVERLAP_METHOD==1
  ALLOCATE(SBUF(BUF_SIZE))
  ALLOCATE(RBUF(BUF_SIZE))
  ALLOCATE(SCOUNTS(2*NDIM), SDISPLS(2*NDIM))
  ALLOCATE(SREQS(2*NDIM),RREQS(2*NDIM))
!
  SCOUNTS=(/SIZE_W,SIZE_E,SIZE_N,SIZE_S,SIZE_F,SIZE_B/)
  SDISPLS=(/0,OFF_E,OFF_N,OFF_S,OFF_F,OFF_B/)
#elif OVERLAP_METHOD==2
  ALLOCATE(SBUF_W(SIZE_W),SBUF_E(SIZE_E),SBUF_N(SIZE_N),SBUF_S(SIZE_S),SBUF_F(SIZE_F),SBUF_B(SIZE_B))
  ALLOCATE(RBUF_W(SIZE_W),RBUF_E(SIZE_E),RBUF_N(SIZE_N),RBUF_S(SIZE_S),RBUF_F(SIZE_F),RBUF_B(SIZE_B))
  ALLOCATE(SREQS(2),RREQS(2))
#endif
!
  

  WRITE(*,150)MYRANK, POS_X, POS_Y, POS_Z,SCOUNTS
  !WRITE(*,*)SDISPLS
  150 Format('Rank ',1I3,'(' 3I3 ,')',': ',6I8)
!
END SUBROUTINE INIT_UPDATE

SUBROUTINE DEALLOC_UPDATE
    USE UPDATE_MOD

#if OVERLAP_METHOD==1
!
  DEALLOCATE(SBUF,RBUF)
  DEALLOCATE(SCOUNTS, SDISPLS)
!
#elif OVERLAP_METHOD==2
!
  
  DEALLOCATE(SBUF_W)
  DEALLOCATE(SBUF_E)
  DEALLOCATE(SBUF_N)
  DEALLOCATE(SBUF_S)
  DEALLOCATE(SBUF_F)
  DEALLOCATE(SBUF_B)
  DEALLOCATE(RBUF_W)
  DEALLOCATE(RBUF_E)
  DEALLOCATE(RBUF_N)
  DEALLOCATE(RBUF_S)
  DEALLOCATE(RBUF_F)
  DEALLOCATE(RBUF_B)
!
#endif
  DEALLOCATE(SREQS, RREQS)
END SUBROUTINE DEALLOC_UPDATE
